const express = require("express");
const http = require("http");
const { Server } = require("socket.io");
const cors = require("cors");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const Database = require("better-sqlite3");

// ☁️ Cloudinary
const { v2: cloudinary } = require("cloudinary");
const { CloudinaryStorage } = require("multer-storage-cloudinary");

const SECRET = process.env.JWT_SECRET;

const app = express();
app.use(cors());
app.use(express.json());

const server = http.createServer(app);
const io = new Server(server, { cors: { origin: "*" } });

// 🔐 Cloudinary config
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

// 📦 SQLite (better-sqlite3)
const dbPath = path.join(__dirname, "database.db");
const db = new Database(dbPath);

// 🧱 Create tables
db.exec(`
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE,
    password TEXT
  );

  CREATE TABLE IF NOT EXISTS messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    text TEXT,
    image TEXT,
    audio TEXT,
    user_id INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );
`);

// ☁️ Cloudinary Storage (image + audio)
const storage = new CloudinaryStorage({
  cloudinary,
  params: {
    folder: "vibechat",
    resource_type: "auto",
  },
});

const upload = multer({ storage });

// 🟢 Root route (fixes "Cannot GET /")
app.get("/", (req, res) => {
  res.json({
    status: "running",
    app: "VibeChat Backend",
  });
});

// 🔐 REGISTER
app.post("/register", async (req, res) => {
  try {
    const { username, password } = req.body;

    const hashed = await bcrypt.hash(password, 10);

    db.prepare("INSERT INTO users(username, password) VALUES(?, ?)")
      .run(username, hashed);

    res.json({ message: "User registered" });
  } catch (err) {
    res.status(400).json({ error: "Username already exists" });
  }
});

// 🔐 LOGIN
app.post("/login", async (req, res) => {
  const { username, password } = req.body;

  const user = db
    .prepare("SELECT * FROM users WHERE username = ?")
    .get(username);

  if (!user) return res.status(404).json({ error: "User not found" });

  const valid = await bcrypt.compare(password, user.password);
  if (!valid)
    return res.status(401).json({ error: "Wrong password" });

  const token = jwt.sign(
    { id: user.id, username: user.username },
    SECRET,
    { expiresIn: "7d" }
  );

  res.json({
    token,
    user: { id: user.id, username: user.username },
  });
});

// 📤 UPLOAD (Cloudinary)
app.post("/upload", upload.single("file"), (req, res) => {
  res.json({
    url: req.file.path, // 🔥 Cloudinary URL
  });
});

// 🔐 SOCKET AUTH
io.use((socket, next) => {
  try {
    const token = socket.handshake.auth.token;
    const user = jwt.verify(token, SECRET);
    socket.user = user;
    next();
  } catch {
    next(new Error("Unauthorized"));
  }
});

// 💬 + 📞 SOCKET LOGIC
io.on("connection", (socket) => {
  console.log("✅ Connected:", socket.user.username, socket.id);

  // Load messages
  const messages = db
    .prepare("SELECT * FROM messages ORDER BY created_at ASC")
    .all();

  socket.emit("load_messages", messages);

  // Send message
  socket.on("send_message", (data) => {
    const { text, image, audio } = data;

    const result = db
      .prepare(
        "INSERT INTO messages(text, image, audio, user_id) VALUES(?, ?, ?, ?)"
      )
      .run(text || null, image || null, audio || null, socket.user.id);

    const newMsg = {
      id: result.lastInsertRowid,
      text,
      image,
      audio,
      user_id: socket.user.id,
      created_at: new Date(),
    };

    io.emit("receive_message", newMsg);
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

// 🔥 ERROR LOGGING
process.on("uncaughtException", (err) => {
  console.error("🔥 Uncaught Exception:", err);
});

process.on("unhandledRejection", (err) => {
  console.error("🔥 Unhandled Rejection:", err);
});

// 🚀 START SERVER
const PORT = process.env.PORT || 4000;

server.listen(PORT, () => {
  console.log("🚀 Server running on port " + PORT);
});