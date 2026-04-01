const express = require("express");
const http = require("http");
const { Server } = require("socket.io");
const cors = require("cors");
const sqlite3 = require("sqlite3").verbose();
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const multer = require("multer");
const path = require("path");

const SECRET = process.env.JWT_SECRET;

const app = express();
app.use(cors());
app.use(express.json());

const server = http.createServer(app);
const io = new Server(server, { cors: { origin: "*" } });

// 📦 DB
const db = new sqlite3.Database("./database.db");

// 📁 Upload setup
const storage = multer.diskStorage({
  destination: (_, __, cb) => cb(null, "uploads/"),
  filename: (_, file, cb) =>
    cb(null, Date.now() + path.extname(file.originalname)),
});
const upload = multer({ storage });

app.use("/uploads", express.static("uploads"));

// 🧱 Tables
db.serialize(() => {
  db.run(`
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE,
      password TEXT
    )
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS messages (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      text TEXT,
      image TEXT,
      audio TEXT,
      user_id INTEGER,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);
});

// 🔐 AUTH
app.post("/register", async (req, res) => {
  const { username, password } = req.body;
  const hashed = await bcrypt.hash(password, 10);

  db.run(
    "INSERT INTO users(username, password) VALUES(?, ?)",
    [username, hashed],
    function (err) {
      if (err) return res.status(400).json({ error: "Username exists" });
      res.json({ id: this.lastID, username });
    }
  );
});

app.post("/login", (req, res) => {
  const { username, password } = req.body;

  db.get(
    "SELECT * FROM users WHERE username = ?",
    [username],
    async (_, user) => {
      if (!user) return res.status(404).json({ error: "User not found" });

      const valid = await bcrypt.compare(password, user.password);
      if (!valid) return res.status(401).json({ error: "Wrong password" });

      const token = jwt.sign(
        { id: user.id, username: user.username },
        SECRET,
        { expiresIn: "7d" }
      );

      res.json({ token, user: { id: user.id, username: user.username } });
    }
  );
});

// 📤 Upload
app.post("/upload", upload.single("file"), (req, res) => {
  res.json({
    url: `http://192.168.x.x:4000/uploads/${req.file.filename}`, // replace IP
  });
});

// 🔐 Socket auth
io.use((socket, next) => {
  try {
    const user = jwt.verify(socket.handshake.auth.token, SECRET);
    socket.user = user;
    next();
  } catch {
    next(new Error("Unauthorized"));
  }
});

// 💬 + 📞 SOCKET
io.on("connection", (socket) => {
  console.log("✅ Connected:", socket.user.username, socket.id);

  // Chat history
  db.all(
    "SELECT * FROM messages ORDER BY created_at ASC",
    [],
    (_, rows) => socket.emit("load_messages", rows)
  );

  // Send message
  socket.on("send_message", (data) => {
    const { text, image, audio } = data;

    db.run(
      "INSERT INTO messages(text, image, audio, user_id) VALUES(?, ?, ?, ?)",
      [text || null, image || null, audio || null, socket.user.id],
      function () {
        io.emit("receive_message", {
          id: this.lastID,
          text,
          image,
          audio,
          user_id: socket.user.id,
          created_at: new Date(),
        });
      }
    );
  });

  // 📞 CALL SIGNALING
  socket.on("call-user", ({ to, offer }) => {
    io.to(to).emit("incoming-call", {
      from: socket.id,
      offer,
    });
  });

  socket.on("answer-call", ({ to, answer }) => {
    io.to(to).emit("call-answered", { answer });
  });

  socket.on("ice-candidate", ({ to, candidate }) => {
    io.to(to).emit("ice-candidate", { candidate });
  });
});
const PORT = process.env.PORT || 4000;
server.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});