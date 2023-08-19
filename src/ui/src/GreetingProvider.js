import React, { useState, useEffect } from "react";
import GreetingContext from "./GreetingContext";
import axios from "axios";
import { API_BASE_URL } from "./config";

const GreetingProvider = ({ children }) => {
  const [greetingItems, setGreetingItems] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Fetch greetings when component mounts
    axios
      .get(`${API_BASE_URL}/api/v1/greeting/latest`)
      .then((response) => {
        const items = response.data.greetingItems;
        if (Array.isArray(items)) {
          setGreetingItems(items);
        } else {
          console.error("Unexpected data format from API:", response.data);
        }
      })
      .catch((error) => {
        console.error("Error fetching greetings:", error);
      })
      .finally(() => {
        setIsLoading(false);
      });
  }, []);

  if (isLoading) {
    return <div>Loading...</div>;
  }

  return (
    <GreetingContext.Provider value={{ greetingItems, setGreetingItems }}>
      {children}
    </GreetingContext.Provider>
  );
};

export default GreetingProvider;
