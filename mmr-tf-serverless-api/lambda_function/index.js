exports.handler = async (event) => {
    console.log("Received event:", JSON.stringify(event, null, 2));

    const AWS = require("aws-sdk");
    const docClient = new AWS.DynamoDB.DocumentClient();
    const tableName = process.env.TABLE_NAME;

    console.log("Using table:", tableName);

    const body = JSON.parse(event.body);

    const item = {
        id: Date.now().toString(),
        transponderId: body.transponderId,
        timestamp: new Date().toISOString(),
        location: body.location
    };

    try {
        await docClient.put({
            TableName: tableName,
            Item: item
        }).promise();

        return {
            statusCode: 200,
            body: JSON.stringify({ message: "Data stored successfully", item })
        };
    } catch (err) {
        console.error("DynamoDB error:", err);
        return {
            statusCode: 500,
            body: JSON.stringify({ message: "Failed to store data", error: err.message })
        };
    }
};