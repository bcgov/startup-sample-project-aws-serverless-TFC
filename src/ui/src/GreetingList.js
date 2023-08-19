import React, { useContext } from "react";
import GreetingContext from "./GreetingContext";

const GreetingList = () => {
  const { greetingItems } = useContext(GreetingContext);

  if (!greetingItems || !Array.isArray(greetingItems)) {
    return <div>No greetings available.</div>;
  }

  const sortedGreetings = [...greetingItems].sort(
    (a, b) => new Date(b.createdAt) - new Date(a.createdAt)
  );

  return (
    <div>
      <h3>Previous greeting selections</h3>
      <ul>
        {sortedGreetings.map((item) => (
          <li key={item.id}>
            {item.greeting}{" "}
            <span>({new Date(item.createdAt).toLocaleString()})</span>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default GreetingList;
