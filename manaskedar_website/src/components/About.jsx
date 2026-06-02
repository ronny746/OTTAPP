import React, { useEffect, useRef } from 'react';

const About = () => {
  const sectionRef = useRef(null);

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add('visible');
          }
        });
      },
      { threshold: 0.2 }
    );

    if (sectionRef.current) {
      observer.observe(sectionRef.current);
    }

    return () => observer.disconnect();
  }, []);

  return (
    <section className="about-section" id="about" ref={sectionRef}>
      <div className="about-container">
        <div className="about-text scroll-reveal left">
          <h2>What is Manaskedar?</h2>
          <div className="divider"></div>
          <p>
            Manaskedar is your ultimate destination for premium entertainment. We bring you a massive library of blockbuster movies, exclusive web series, and original shows across multiple genres and languages.
          </p>
          <p>
            Whether you are looking for heart-pounding action, laugh-out-loud comedies, or gripping dramas, Manaskedar delivers a cinematic experience right to your screen.
          </p>
        </div>
        <div className="about-image scroll-reveal right">
          <div className="image-wrapper glass-panel">
            <img src="/assets/app_mockup.png" alt="Manaskedar App UI Mockup" />
          </div>
        </div>
      </div>
    </section>
  );
};

export default About;
