const AWS = require("aws-sdk");
const crypto = require("crypto");

// Create a new DynamoDB instance
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  console.log("Event:", event);
  let body;
  let greeting;

  try {
    body = JSON.parse(event.body);
    greeting = body.greeting;
  } catch {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: "Invalid request body" }),
    };
  }

  if (!body.greeting) {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: "Greeting is required" }),
    };
  }

  const params = {
    TableName: process.env.DYNAMODB_TABLE_NAME,
    Item: {
      id: crypto.randomBytes(16).toString("hex"), // Generates a unique hex string
      greeting: greeting,
      createdAt: new Date().toISOString(),
    },
  };

  try {
    await dynamodb.put(params).promise();

    return {
      statusCode: 200,
      body: JSON.stringify(params.Item),
    };
  } catch (error) {
    console.error("Error:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: "Internal server error" }),
    };
  }
};
