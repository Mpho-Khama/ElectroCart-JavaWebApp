<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Track Your Order</title>
    <style>
        /* General body styling */
        body {
            font-family: Arial, sans-serif;
            background-color: #f5f6fa;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }

        /* Container for the form */
        .track-container {
            background-color: #fff;
            padding: 30px 40px;
            border-radius: 10px;
            box-shadow: 0 8px 20px rgba(0,0,0,0.1);
            width: 350px;
            text-align: center;
        }

        h2 {
            margin-bottom: 25px;
            color: #333;
        }

        /* Input styling */
        input[type="text"] {
            width: 100%;
            padding: 12px 15px;
            margin-bottom: 20px;
            border: 1px solid #ccc;
            border-radius: 6px;
            font-size: 16px;
            box-sizing: border-box;
            transition: border-color 0.3s;
        }

        input[type="text"]:focus {
            border-color: #007bff;
            outline: none;
        }

        /* Button styling */
        button {
            width: 100%;
            padding: 12px;
            background-color: #007bff;
            color: #fff;
            font-size: 16px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            transition: background-color 0.3s;
        }

        button:hover {
            background-color: #0056b3;
        }

        /* Error message */
        .error-message {
            color: red;
            font-weight: bold;
            margin-top: 10px;
        }

        /* Responsive for small screens */
        @media (max-width: 400px) {
            .track-container {
                width: 90%;
                padding: 20px;
            }
        }
    </style>
</head>
<body>
    <div class="track-container">
        <h2>Track Your Order</h2>

        <form action="TrackOrderServlet" method="get">
            <label for="trackingCode">Enter Tracking Code:</label>
            <input type="text" id="trackingCode" name="trackingCode" required>
            <button type="submit">Track Order</button>
        </form>

        <% if(request.getParameter("error") != null) { %>
            <p class="error-message"><%= request.getParameter("error") %></p>
        <% } %>
    </div>
</body>
</html>
