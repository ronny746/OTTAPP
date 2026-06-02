import React, { useEffect, useState } from 'react';

const Hero = () => {
  const [images] = useState([
    '/assets/hero_banner.png',
    '/assets/app_mockup.png',
    '/assets/hero_banner.png',
    '/assets/app_mockup.png'
  ]);

  return (
    <section className="hero-section" id="hero">
      <div className="hero-container">
        <div className="hero-text animate-up visible">
          <h1>
            <span style={{ display: 'block' }}>Your</span>
            <span style={{ display: 'block' }}>Gateway to</span>
            <span className="text-gradient">Digital</span><br/>
            <span className="text-gradient">Playground</span>
          </h1>
          <p>
            Experience the best in entertainment. Manaskedar brings you closer to the stories you love with a seamless streaming experience, anywhere, anytime.
          </p>
          <a href="/" onClick={(e) => { e.preventDefault(); document.getElementById('features')?.scrollIntoView({ behavior: 'smooth' }); }} className="btn-primary">Explore</a>
        </div>
      </div>
      
      <div className="hero-slider-wrapper">
        <div className="hero-slide-track">
          {images.map((src, idx) => (
            <img key={`l-${idx}`} src={src} alt="Hero slide" />
          ))}
          {images.map((src, idx) => (
            <img key={`l2-${idx}`} src={src} alt="Hero slide loop" />
          ))}
        </div>
        <div className="hero-slide-track reverse">
          {images.map((src, idx) => (
            <img key={`r-${idx}`} src={src} alt="Hero slide" />
          ))}
          {images.map((src, idx) => (
            <img key={`r2-${idx}`} src={src} alt="Hero slide loop" />
          ))}
        </div>
      </div>
    </section>
  );
};

export default Hero;
