require("dotenv").config(); // Load environment variables
const express = require("express");
const http = require("http");
const { Server } = require("socket.io");
const cors = require("cors");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const multer = require("multer");
const mongoose = require("mongoose");

// ☁️ Cloudinary
const { v2: cloudinary } = require("cloudinary");
const { CloudinaryStorage } = require("multer-storage-cloudinary");

const SECRET = process.env.JWT_SECRET;
if (!SECRET) {
  console.error("⚠️ WARNING: JWT_SECRET is missing from environment variables.");
}

const app = express();
app.use(cors());
app.use(express.json());

const server = http.createServer(app);
const io = new Server(server, { cors: { origin: "*" } });

// 📦 MongoDB Connection (Replace MONGO_URI in your Render Dashboard)
mongoose.connect(process.env.MONGO_URI || "mongodb://localhost:27017/vibechat")
  .then(() => console.log("📦 Connected to MongoDB"))
  .catch(err => console.error("🔥 MongoDB Connection Error:", err));

// 🧱 MongoDB Models
const UserSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  password: { type: String, required: true }
});
const User = mongoose.model("User", UserSchema);

const MessageSchema = new mongoose.Schema({
  text: String,
  image: String,
  audio: String,
  encryption_key: String, // Added for E2EE
  user_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  created_at: { type: Date, default: Date.now }
});
const Message = mongoose.model("Message", MessageSchema);

// 🔐 Cloudinary config
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

// ☁️ Cloudinary Storage (Set to RAW for encrypted files)
const storage = new CloudinaryStorage({
  cloudinary,
  params: {
    folder: "vibechat",
    resource_type: "raw", // 🔥 CRITICAL FOR E2EE: Tells Cloudinary not to process the encrypted gibberish
  },
});
const upload = multer({ storage });

// 🟢 Root route
app.get("/", (req, res) => res.json({ status: "running", app: "VibeChat Backend" }));

// 🔐 REGISTER
app.post("/register", async (req, res) => {
  try {
    const { username, password } = req.body;
    
    // Check if user exists
    const existingUser = await User.findOne({ username });
    if (existingUser) {
      return res.status(400).json({ error: "Username already exists" });
    }

    const hashed = await bcrypt.hash(password, 10);
    const newUser = new User({ username, password: hashed });
    await newUser.save();

    res.json({ message: "User registered successfully" });
  } catch (err) {
    console.error("Register Error:", err);
    res.status(500).json({ error: "An internal server error occurred" });
  }
});

// 🔐 LOGIN (Fixed with try/catch)
app.post("/login", async (req, res) => {
  try {
    const { username, password } = req.body;

    const user = await User.findOne({ username });
    if (!user) return res.status(404).json({ error: "User not found" });

    const valid = await bcrypt.compare(password, user.password);
    if (!valid) return res.status(401).json({ error: "Wrong password" });

    if (!SECRET) return res.status(500).json({ error: "Server misconfiguration" });

    const token = jwt.sign(
      { id: user._id, username: user.username },
      SECRET,
      { expiresIn: "7d" }
    );

    res.json({
      token,
      user: { id: user._id, username: user.username },
    });
  } catch (error) {
    console.error("Login Error:", error);
    res.status(500).json({ error: "An internal server error occurred" });
  }
});

// 📤 UPLOAD (Cloudinary)
app.post("/upload", upload.single("file"), (req, res) => {
  if (!req.file) return res.status(400).json({ error: "No file uploaded" });
  res.json({ url: req.file.path });
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

// 💬 SOCKET LOGIC
io.on("connection", async (socket) => {
  console.log("✅ Connected:", socket.user.username, socket.id);

  // Load messages from MongoDB
  const messages = await Message.find().sort({ created_at: 1 }).lean();
  socket.emit("load_messages", messages);

  // Send message
  socket.on("send_message", async (data) => {
    const { text, image, audio, encryption_key } = data;

    const newMsg = new Message({
      text: text || null,
      image: image || null,
      audio: audio || null,
      encryption_key: encryption_key || null,
      user_id: socket.user.id,
    });
    
    await newMsg.save();

    io.emit("receive_message", {
      id: newMsg._id,
      text: newMsg.text,
      image: newMsg.image,
      audio: newMsg.audio,
      encryption_key: newMsg.encryption_key,
      user_id: socket.user.id,
      created_at: newMsg.created_at,
    });
  });

  // 📞 CALL SIGNALING (Unchanged)
  socket.on("call-user", ({ to, offer }) => io.to(to).emit("incoming-call", { from: socket.id, offer }));
  socket.on("answer-call", ({ to, answer }) => io.to(to).emit("call-answered", { answer }));
  socket.on("ice-candidate", ({ to, candidate }) => io.to(to).emit("ice-candidate", { candidate }));
});

const PORT = process.env.PORT || 4000;
server.listen(PORT, () => console.log("🚀 Server running on port " + PORT));