// src/GreetingList.js

import React, { useState, useEffect } from "react";
import axios from "axios";

import { API_BASE_URL } from "./config";

const GreetingList = () => {
  const [greetingItems, setGreetingItems] = useState([]);

  useEffect(() => {
    // Fetch greetings from the API
    axios
      .get(`${API_BASE_URL}/api/v1/greeting/latest`)
      .then((response) => {
        // Sort the items by date in descending order (newest first)
        const sortedItems = response.data.greetingItems.sort(
          (a, b) => new Date(b.createdAt) - new Date(a.createdAt)
        );
        setGreetingItems(sortedItems);
      })
      .catch((error) => {
        console.error("Error fetching greetings:", error);
      });
  }, []);

  return (
    <div>
      <h2>Latest Greetings</h2>
      <ul>
        {greetingItems.map((item) => (
          <li key={item.id}>
            {item.greeting} (at {new Date(item.createdAt).toLocaleString()})
          </li>
        ))}
      </ul>
    </div>
  );
};

export default GreetingList;
