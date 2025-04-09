<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vehicle Controller</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            line-height: 1.6;
            color: #24292e;
            max-width: 1000px;
            margin: 0 auto;
            padding: 20px;
        }
        h1 {
            padding-bottom: 10px;
            border-bottom: 1px solid #eaecef;
        }
        .image-container {
            display: flex;
            justify-content: center;
            flex-wrap: wrap;
            gap: 20px;
            margin: 30px 0;
        }
        .image-container img {
            max-width: 100%;
            height: auto;
            border-radius: 5px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        @media (min-width: 768px) {
            .image-container img {
                max-width: 45%;
            }
        }
        .features {
            background-color: #f6f8fa;
            padding: 20px;
            border-radius: 5px;
            margin: 20px 0;
        }
        .technologies {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin: 20px 0;
        }
        .tech-badge {
            background-color: #0366d6;
            color: white;
            padding: 5px 10px;
            border-radius: 15px;
            font-size: 14px;
        }
        footer {
            margin-top: 30px;
            font-size: 14px;
            color: #6a737d;
            text-align: center;
        }
    </style>
</head>
<body>
    <header>
        <h1>Vehicle Controller</h1>
        <p>A modern mobile application for remotely controlling and monitoring vehicles, providing real-time data and control capabilities.</p>
    </header>

    <div class="image-container">
        <img src="https://aidenwood.me/imgs/app.png" alt="Vehicle Controller App">
        <img src="https://aidenwood.me/imgs/lilscreen.png" alt="Vehicle Display">
    </div>

    <section class="features">
        <h2>Features</h2>
        <ul>
            <li>Real-time vehicle monitoring and diagnostics</li>
            <li>Remote locking/unlocking with secure authentication</li>
            <li>GPS tracking with location history</li>
            <li>Custom app appearance with selectable app icons</li>
            <li>Comprehensive settings management</li>
            <li>Interactive dashboard with vehicle metrics</li>
            <li>Proximity-based automatic functions</li>
            <li>Alarm system integration and notifications</li>
        </ul>
    </section>

    <h2>Technologies</h2>
    <div class="technologies">
        <span class="tech-badge">SwiftUI</span>
        <span class="tech-badge">iOS 15+</span>
        <span class="tech-badge">Flask</span>
        <span class="tech-badge">Raspberry Pi</span>
        <span class="tech-badge">SQLite</span>
        <span class="tech-badge">RESTful API</span>
        <span class="tech-badge">GPIO</span>
        <span class="tech-badge">CoreData</span>
    </div>

    <section>
        <h2>Architecture</h2>
        <p>The system consists of an iOS application built with SwiftUI, a backend server running on Raspberry Pi, and vehicle interface components for hardware control. The application communicates with the server via a custom RESTful API, which then interfaces with the vehicle systems.</p>
    </section>

    <footer>
        <p>© 2025 Vehicle Controller. All rights reserved.</p>
    </footer>
</body>
</html>
