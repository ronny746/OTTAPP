import React, { useEffect, useState } from 'react';

const Preloader = () => {
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const timer = setTimeout(() => {
      setLoading(false);
    }, 1500); // 1.5 seconds preloader
    return () => clearTimeout(timer);
  }, []);

  return (
    <div className={`preloader ${!loading ? 'hidden' : ''}`}>
      <svg className="loader-triangle" viewBox="0 0 86 80">
        <polygon points="43 8 79 72 7 72"></polygon>
      </svg>
      <h2 className="preloader-text">MANASKEDAR</h2>
    </div>
  );
};

export default Preloader;
