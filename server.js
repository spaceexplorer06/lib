require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const { MongoClient } = require('mongodb');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// MongoDB connection string
const uri = process.env.MONGO_URI;
let db;

// Connect to MongoDB Atlas
async function connectToDatabase() {
  try {
    console.log('Attempting to connect to MongoDB Atlas...');
    const client = await MongoClient.connect(uri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    db = client.db('eventhive'); // Corrected to lowercase 'eventhive'
    console.log('Connected to MongoDB Atlas');
    
    // Start the server after DB is connected
    app.listen(process.env.PORT || 3000, () => {
      console.log(`Server running on http://localhost:${process.env.PORT || 3000}`);
    });
  } catch (err) {
    console.error('Failed to connect to MongoDB:', err);
    process.exit(1); // Exit if connection fails
  }
}

connectToDatabase();

// Root route: added to handle "Cannot GET /" error
app.get('/', (req, res) => {
  res.send('Welcome to EventHive API!');
});

// Fetch events from the database
app.get('/events', async (req, res) => {
  if (!db) {
    return res.status(503).send({ error: 'Database not connected yet' });
  }

  try {
    const events = await db.collection('events').find().toArray();
    res.status(200).json(events); // Return events as JSON
  } catch (error) {
    console.error('Error fetching events:', error);
    res.status(500).send({ error: 'Failed to fetch events' });
  }
});
