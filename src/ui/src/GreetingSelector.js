import React, { useContext, useState } from "react";
import GreetingContext from "./GreetingContext";
import axios from "axios";
import { API_BASE_URL } from "./config";

const GreetingSelector = () => {
  const { greetingItems, setGreetingItems } = useContext(GreetingContext);
  const [selectedGreeting, setSelectedGreeting] = useState("Aloha");
  const [isLoading, setIsLoading] = useState(false);

  const handleGreetingChange = (event) => {
    setSelectedGreeting(event.target.value);
  };

  const handleSendGreeting = () => {
    setIsLoading(true);
    axios
      .post(`${API_BASE_URL}/api/v1/greeting`, { greeting: selectedGreeting })
      .then((response) => {
        const newGreetingItem = response.data;
        setGreetingItems([newGreetingItem, ...greetingItems]);
        setSelectedGreeting("");
      })
      .catch((error) => {
        console.error("Error sending greeting:", error);
      })
      .finally(() => {
        setIsLoading(false);
      });
  };

  return (
    <div>
      <h3>Select your favorite greeting</h3>
      <select value={selectedGreeting} onChange={handleGreetingChange}>
        <option value="Aloha">Aloha</option>
        <option value="Bonjour">Bonjour</option>
        <option value="Greetings and salutations">
          Greetings and salutations
        </option>
        <option value="Hello">Hello</option>
        <option value="Howdy">Howdy</option>
        <option value="Konichiwa">Konichiwa</option>
      </select>
      <button onClick={handleSendGreeting} disabled={isLoading}>
        {isLoading ? "Sending..." : "Send Greeting"}
      </button>
    </div>
  );
};

export default GreetingSelector;
