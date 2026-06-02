import React from 'react';

const Footer = () => {
  return (
    <footer className="footer-section">
      <div className="footer-content">
        <div className="footer-brand">
          <h2>MANASKEDAR</h2>
          <p>&copy; {new Date().getFullYear()} All rights reserved.</p>
        </div>
        <div className="footer-links">
          <a href="/">Terms</a>
          <a href="/">Privacy</a>
          <a href="/">Contact</a>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
