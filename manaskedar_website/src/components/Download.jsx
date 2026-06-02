import React, { useEffect, useRef } from 'react';

const Download = () => {
  const sectionRef = useRef(null);

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting) {
          entries[0].target.classList.add('visible');
        }
      },
      { threshold: 0.3 }
    );

    if (sectionRef.current) {
      observer.observe(sectionRef.current);
    }

    return () => observer.disconnect();
  }, []);

  return (
    <section className="download-section animate-up" id="download" ref={sectionRef}>
      <div className="download-box glass-panel">
        <h2>Download <span className="text-gradient">Manaskedar</span></h2>
        <p>Your gateway to the digital playground is just one tap away.</p>
        <div className="download-buttons">
          <a href="https://play.google.com/store/apps/details?id=com.manaskedar.app" target="_blank" rel="noopener noreferrer" className="store-btn">
            <svg viewBox="0 0 24 24" fill="currentColor">
              <path d="M3.609 1.814L13.792 12.001L3.609 22.188C3.218 21.848 3 21.365 3 20.803V3.199C3 2.637 3.218 2.154 3.609 1.814ZM14.856 10.941L18.736 8.705C19.78 8.106 19.78 7.135 18.736 6.536L14.856 4.301L14.856 10.941ZM14.856 13.061L14.856 19.701L18.736 17.466C19.78 16.867 19.78 15.896 18.736 15.297L14.856 13.061ZM14.323 12.001L4.667 2.342L14.323 12.001ZM14.323 12.001L4.667 21.66L14.323 12.001Z"/>
            </svg>
            <div>Google Play</div>
          </a>
        </div>
      </div>
    </section>
  );
};

export default Download;
