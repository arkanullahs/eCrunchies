const express = require('express');
const bodyParser = require('body-parser');
const app = express();

app.use(bodyParser.json());

// Endpoint to receive order data from the user client
app.post('/api/orders', (req, res) => {
  const orderData = req.body; // Access the incoming order data
  
  // Log the received data
  console.log('Received order data:', orderData);

  // Simulate sending received order data back to the restaurant client
  res.json(orderData);
});

// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
