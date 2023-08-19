import React, { useState } from "react";
import axios from "axios";
import { API_BASE_URL } from "./config";

function GreetingSelector() {
  const [greeting, setGreeting] = useState("hello");

  const handleGreetingChange = (e) => {
    setGreeting(e.target.value);
  };

  const handleSubmit = async () => {
    try {
      const response = await axios.post(`${API_BASE_URL}/api/v1/greeting`, {
        greeting,
      });
      console.log("Response:", response.data);
      // Handle success - perhaps show a success message to the user
    } catch (error) {
      console.error("Error posting greeting:", error);
      // Handle error - show an error message to the user
    }
  };

  return (
    <div>
      <select value={greeting} onChange={handleGreetingChange}>
        <option value="hello">hello</option>
        <option value="howdy">howdy</option>
        <option value="bonjour">bonjour</option>
      </select>
      <button onClick={handleSubmit}>Submit</button>
    </div>
  );
}

export default GreetingSelector;
