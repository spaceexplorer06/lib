const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(express.json());

// ✅ MongoDB Atlas connection
const MONGO_URI = "mongodb+srv://eventadmin:moinakdey17@cluster0.dtvoi.mongodb.net/eventhive?retryWrites=true&w=majority&appName=Cluster0";

mongoose
  .connect(MONGO_URI)
  .then(() => console.log("✅ MongoDB Atlas connected"))
  .catch((err) => console.error("❌ MongoDB connection error:", err));

// Event Schema
const eventSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: String,
  location: String,
  startDate: String,
  endDate: String,
  registrationStart: String,
  registrationEnd: String,
  isPublished: { type: Boolean, default: false },
  tickets: [
    {
      type: { type: String },
      price: Number,
      quantity: Number,
    },
  ],
});

const Event = mongoose.model("Event", eventSchema);

// ✅ Route: Create Event
app.post("/create-event", async (req, res) => {
  try {
    console.log("📩 Incoming Event Data:", req.body);

    const event = new Event(req.body);
    await event.save();

    res.status(201).json({
      success: true,
      message: "✅ Event created successfully!",
      event: event,
    });
  } catch (err) {
    console.error("❌ Error creating event:", err.message);
    res.status(400).json({ success: false, error: err.message });
  }
});

// ✅ Route: Get All Events
app.get("/events", async (req, res) => {
  try {
    const events = await Event.find();
    res.status(200).json(events);
  } catch (err) {
    res.status(500).json({ error: "Failed to fetch events" });
  }
});

// ✅ Route: Get Single Event by ID
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

// Root route
app.get("/", (req, res) => {
  res.send("🎉 EventHive API is running fine!");
});

// ✅ Listen on 0.0.0.0 for LAN access
app.listen(PORT, "0.0.0.0", () => {
  console.log(`🚀 Server running at http://0.0.0.0:${PORT}`);
});
