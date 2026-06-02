import React, { useEffect } from 'react';

const Header = () => {
  useEffect(() => {
    // Scroll progress logic
    const handleScroll = () => {
      const scrollTotal = document.documentElement.scrollTop;
      const height = document.documentElement.scrollHeight - document.documentElement.clientHeight;
      const scrollRatio = scrollTotal / height;
      const progressBar = document.getElementById('progress-bar');
      if (progressBar) {
        progressBar.style.transform = `scaleX(${scrollRatio})`;
      }
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <>
      <div id="progress-bar" className="scroll-progress"></div>
      <header className="header">
        <div className="header-container">
          <a href="/" className="logo">MANASKEDAR</a>
          <ul className="nav-links">
            <li><a href="/" onClick={(e) => { e.preventDefault(); document.getElementById('features')?.scrollIntoView({ behavior: 'smooth' }); }}>Discover</a></li>
            <li><a href="/" onClick={(e) => { e.preventDefault(); document.getElementById('download')?.scrollIntoView({ behavior: 'smooth' }); }}>Our App</a></li>
          </ul>
          <div className="hamburger">
            <span></span>
            <span></span>
          </div>
        </div>
      </header>
    </>
  );
};

export default Header;
