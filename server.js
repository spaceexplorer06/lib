// server.js
const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const PDFDocument = require("pdfkit");
require("dotenv").config();

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || "supersecretkey";

// Middleware
app.use(cors());
app.use(express.json());

// MongoDB connection
const MONGO_URI =
  process.env.MONGO_URI ||
  "mongodb+srv://eventadmin:moinakdey17@cluster0.dtvoi.mongodb.net/eventhive?retryWrites=true&w=majority";

mongoose
  .connect(MONGO_URI)
  .then(() => console.log("✅ MongoDB connected"))
  .catch((err) => console.error("❌ MongoDB connection error:", err));

// ======================= Schemas =======================

// User Schema
const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  passwordHash: { type: String, required: true },
});
const User = mongoose.model("User", userSchema);

// Event Schema
const eventSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: { type: String, default: "No description provided" },
  location: { type: String, default: "Not specified" },
  startDate: { type: String, default: "TBD" },
  endDate: { type: String, default: "TBD" },
  registrationStart: { type: String, default: "" },
  registrationEnd: { type: String, default: "" },
  isPublished: { type: Boolean, default: false },
  eventType: { type: String, required: true }, // Added eventType
  tickets: [
    {
      type: { type: String, required: true },
      price: { type: Number, required: true },
      quantity: { type: Number, required: true, min: 0 },
    },
  ],
});
const Event = mongoose.model("Event", eventSchema);

// ======================= Auth Middleware =======================
const authenticate = (req, res, next) => {
  const token = req.headers.authorization?.split(" ")[1];
  if (!token) return res.status(401).json({ success: false, message: "No token provided" });

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.userId = decoded.userId;
    next();
  } catch (err) {
    res.status(401).json({ success: false, message: "Invalid token" });
  }
};

// ======================= Routes =======================

// Registration
app.post("/register", async (req, res) => {
  try {
    const { name, email, password } = req.body;
    if (!name || !email || !password)
      return res.status(400).json({ success: false, message: "All fields required" });

    const existingUser = await User.findOne({ email });
    if (existingUser) return res.status(400).json({ success: false, message: "Email already registered" });

    const passwordHash = await bcrypt.hash(password, 10);
    const user = new User({ name, email, passwordHash });
    await user.save();

    res.status(201).json({ success: true, message: "User registered successfully!" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// Login
app.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    if (!user) return res.status(400).json({ success: false, message: "Invalid email or password" });

    const isMatch = await bcrypt.compare(password, user.passwordHash);
    if (!isMatch) return res.status(400).json({ success: false, message: "Invalid email or password" });

    const token = jwt.sign({ userId: user._id }, JWT_SECRET, { expiresIn: "7d" });
    res.status(200).json({ success: true, token, user: { name: user.name, email: user.email } });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// Create Event
app.post("/create-event", authenticate, async (req, res) => {
  try {
    const { name, description, location, startDate, endDate, registrationStart, registrationEnd, tickets, eventType } = req.body;

    if (!eventType) {
      return res.status(400).json({ success: false, message: "Event type is required" });
    }

    const event = new Event({ name, description, location, startDate, endDate, registrationStart, registrationEnd, tickets, eventType });
    await event.save();

    res.status(201).json({ success: true, message: "Event created successfully!", event });
  } catch (err) {
    console.error("Error creating event:", err.message);
    res.status(400).json({ success: false, error: err.message });
  }
});

// Get all events
app.get("/events", async (req, res) => {
  try {
    const events = await Event.find();
    res.status(200).json(events);
  } catch (err) {
    console.error("Failed to fetch events:", err.message);
    res.status(500).json({ error: "Failed to fetch events" });
  }
});

// Get single event
app.get("/events/:id", async (req, res) => {
  try {
    const event = await Event.findById(req.params.id);
    if (!event) return res.status(404).json({ error: "Event not found" });
    res.status(200).json(event);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch event" });
  }
});

// Delete event
app.delete("/events/:id", authenticate, async (req, res) => {
  try {
    const deletedEvent = await Event.findByIdAndDelete(req.params.id);
    if (!deletedEvent) return res.status(404).json({ success: false, message: "Event not found" });
    res.status(200).json({ success: true, message: "Event deleted successfully" });
  } catch (err) {
    console.error("Error deleting event:", err.message);
    res.status(500).json({ success: false, message: "Failed to delete event" });
  }
});

// ======================= Book Ticket =======================
app.post("/events/:id/book-ticket", authenticate, async (req, res) => {
  const eventId = req.params.id;
  const { type, quantity } = req.body;

  if (!type || !quantity || quantity <= 0)
    return res.status(400).json({ success: false, message: "Ticket type and quantity are required" });

  try {
    const event = await Event.findById(eventId);
    if (!event) return res.status(404).json({ success: false, message: "Event not found" });

    const ticket = event.tickets.find(t => t.type.toLowerCase() === type.toLowerCase());
    if (!ticket) return res.status(404).json({ success: false, message: `Ticket type '${type}' not found` });

    if (ticket.quantity < quantity)
      return res.status(400).json({ success: false, message: `Not enough tickets. Only ${ticket.quantity} left` });

    ticket.quantity -= quantity;
    await event.save();

    // Generate PDF in memory
    const doc = new PDFDocument({ size: 'A4', margin: 50 });
    let buffers = [];
    doc.on("data", buffers.push.bind(buffers));
    doc.on("end", () => {
      const pdfBase64 = Buffer.concat(buffers).toString("base64");
      res.status(200).json({
        success: true,
        message: "Tickets booked successfully!",
        bookedTicket: {
          eventId: event._id,
          eventName: event.name,
          eventType: event.eventType, // Include eventType
          ticketType: ticket.type,
          price: ticket.price,
          bookedQuantity: quantity,
          remainingQuantity: ticket.quantity,
          pdf: pdfBase64,
        },
      });
    });

    doc.fontSize(22).text("🎫 Ticket Confirmation", { align: "center" });
    doc.moveDown();
    doc.fontSize(16).text(`Event: ${event.name}`);
    doc.text(`Event Type: ${event.eventType}`);
    doc.text(`Ticket Type: ${ticket.type}`);
    doc.text(`Quantity: ${quantity}`);
    doc.text(`Price per ticket: ₹${ticket.price}`);
    doc.text(`Total Amount: ₹${ticket.price * quantity}`);
    doc.text(`Location: ${event.location}`);
    doc.text(`Event Date: ${event.startDate} - ${event.endDate}`);
    doc.moveDown();
    doc.text("Show this ticket at the entrance.", { align: "center" });

    doc.end();
  } catch (err) {
    console.error("Error booking ticket:", err);
    res.status(500).json({ success: false, message: "Failed to book ticket" });
  }
});

// Root
app.get("/", (req, res) => res.send("🎉 EventHive API is running!"));

// Start server
app.listen(PORT, "0.0.0.0", () => console.log(`🚀 Server running at http://0.0.0.0:${PORT}`));
