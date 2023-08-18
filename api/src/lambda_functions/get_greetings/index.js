const AWS = require("aws-sdk");

// Create a new DynamoDB instance
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  const params = {
    TableName: process.env.DYNAMODB_TABLE_NAME,
  };

  try {
    const result = await dynamodb.scan(params).promise();

    const greetings = result.Items.map((item) => ({
      greeting: item.greeting,
      timestamp: item.timestamp,
    }));

    return {
      statusCode: 200,
      body: JSON.stringify(greetings),
    };
  } catch (error) {
    console.error("Error retrieving greetings:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: "Error retrieving greetings" }),
    };
  }
};
