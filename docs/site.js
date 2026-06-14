document.addEventListener("DOMContentLoaded", () => {
  // --- Theme Toggle ---
  const themeToggle = document.createElement("button");
  themeToggle.className = "theme-toggle-btn";
  themeToggle.setAttribute("aria-label", "Toggle dark/light theme");
  themeToggle.innerHTML = `
    <svg class="sun-icon" viewBox="0 0 24 24" width="20" height="20" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="5"></circle><line x1="12" y1="1" x2="12" y2="3"></line><line x1="12" y1="21" x2="12" y2="23"></line><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line><line x1="1" y1="12" x2="3" y2="12"></line><line x1="21" y1="12" x2="23" y2="12"></line><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line></svg>
    <svg class="moon-icon" viewBox="0 0 24 24" width="20" height="20" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path></svg>
  `;
  
  const siteHeader = document.querySelector(".site-header");
  if (siteHeader) {
    siteHeader.appendChild(themeToggle);
  }

  const currentTheme = localStorage.getItem("theme") || "dark"; // Default to dark for premium aesthetics
  document.documentElement.setAttribute("data-theme", currentTheme);

  themeToggle.addEventListener("click", () => {
    let theme = document.documentElement.getAttribute("data-theme");
    let nextTheme = theme === "dark" ? "light" : "dark";
    document.documentElement.setAttribute("data-theme", nextTheme);
    localStorage.setItem("theme", nextTheme);
  });

  // --- Scroll Animations ---
  const fadeElems = document.querySelectorAll("article, .story, .beta, .section-heading, .intro");
  
  const scrollObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add("visible");
        scrollObserver.unobserve(entry.target);
      }
    });
  }, { threshold: 0.1 });

  fadeElems.forEach(el => {
    el.classList.add("scroll-fade");
    scrollObserver.observe(el);
  });

  // --- Reflection Simulator ---
  const presets = {
    stress: {
      transcript: "Today felt hard because the demo, project setup, and messages all needed attention at the same time, and I didn't know what to finish first.",
      title: "Make the load smaller",
      emotion: "Overloaded",
      summary: "The simultaneous arrival of configuration tasks, meeting updates, and incoming alerts left you feeling scattered and overwhelmed.",
      insight: "When context-switching exceeds your capacity, naming the load is the first step to reclaiming focus.",
      expressionMoment: "I didn't know what to finish first.",
      quote: "A smaller list makes a steadier day.",
      confidenceScore: "0.91",
      quest: "Choose the single smallest useful task and leave the rest for the next pass."
    },
    repair: {
      transcript: "My friend said something hurtful during lunch and I want to reply, but I'm afraid of saying the wrong thing and making things worse.",
      title: "Pause before you respond",
      emotion: "Careful",
      summary: "You felt hurt by a friend's words, but you are choosing to pause because you want to preserve the relationship.",
      insight: "A boundary is stronger when it names what you need rather than matching the other person's intensity.",
      expressionMoment: "I'm afraid of making things worse.",
      quote: "A gentle boundary is a gift to the relationship.",
      confidenceScore: "0.86",
      quest: "Write one calm draft that names the impact and asks for a time to talk."
    },
    pride: {
      transcript: "I felt proud because I explained the next step clearly during our team sync and everyone understood.",
      title: "You noticed a meaningful win",
      emotion: "Proud",
      summary: "You felt proud after preparing and communicating clearly in the team sync, helping the team align.",
      insight: "Clear communication is an active practice that pays off in shared understanding.",
      expressionMoment: "Everyone understood.",
      quote: "A clear sentence is a bridge to others.",
      confidenceScore: "0.80",
      quest: "Write down what helped you explain the idea clearly today."
    }
  };

  const textarea = document.getElementById("sim-textarea");
  const reflectBtn = document.getElementById("sim-reflect-btn");
  const pinguMascot = document.getElementById("pingu-mascot-container");
  const outputCard = document.getElementById("sim-output-card");
  const presetButtons = document.querySelectorAll(".preset-btn");
  
  if (textarea && reflectBtn) {
    presetButtons.forEach(btn => {
      btn.addEventListener("click", () => {
        const type = btn.getAttribute("data-preset");
        presetButtons.forEach(b => b.classList.remove("active"));
        btn.classList.add("active");
        
        // Nod mascot when preset is chosen
        triggerMascotAction("nod");
        
        // Typing animation simulation
        textarea.value = "";
        let i = 0;
        const txt = presets[type].transcript;
        reflectBtn.disabled = true;
        
        function typeWriter() {
          if (i < txt.length) {
            textarea.value += txt.charAt(i);
            i++;
            setTimeout(typeWriter, 15);
          } else {
            reflectBtn.disabled = false;
          }
        }
        typeWriter();
      });
    });

    textarea.addEventListener("input", () => {
      // Mascot blinks when typing
      if (Math.random() > 0.8) {
        triggerMascotAction("blink");
      }
    });

    reflectBtn.addEventListener("click", async () => {
      const text = textarea.value.trim();
      if (!text) return;

      reflectBtn.disabled = true;
      outputCard.innerHTML = `
        <div class="sim-loader">
          <div class="spinner"></div>
          <p>Analyzing transcript with Apple Intelligence...</p>
        </div>
      `;
      outputCard.classList.remove("show");

      // Animate mascot while analyzing
      triggerMascotAction("bounce");

      // Match preset if possible, otherwise use local-style fallback
      let matchedData = null;
      for (const key in presets) {
        if (text.toLowerCase().includes(key) || text.length > 50 && presets[key].transcript.substring(0, 10).toLowerCase() === text.substring(0, 10).toLowerCase()) {
          matchedData = presets[key];
          break;
        }
      }

      if (!matchedData) {
        // Fallback generator
        matchedData = {
          title: "You checked in with yourself",
          emotion: "Thoughtful",
          summary: "You took a moment to reflect on your day and gave structure to your thoughts.",
          insight: "Regular check-ins build emotional agility, allowing you to respond rather than react.",
          expressionMoment: text.substring(0, Math.min(text.length, 30)) + "...",
          quote: "Honesty with yourself is the first step to calm.",
          confidenceScore: "0.75",
          quest: "Choose one small action that makes the next hour feel structured."
        };
      }

      await new Promise(resolve => setTimeout(resolve, 1800)); // Simulate AI delay

      outputCard.innerHTML = `
        <div class="reflection-result-card">
          <div class="result-header">
            <span class="result-emotion">${matchedData.emotion}</span>
            <span class="result-confidence">Confidence: ${matchedData.confidenceScore}</span>
          </div>
          <h4 class="result-title">${matchedData.title}</h4>
          
          <div class="result-section">
            <h5>Summary</h5>
            <p>${matchedData.summary}</p>
          </div>
          
          <div class="result-section">
            <h5>Insight</h5>
            <p>${matchedData.insight}</p>
          </div>
          
          <blockquote class="result-quote">
            <p>"${matchedData.quote}"</p>
            <cite>Your memorable moment: <span>${matchedData.expressionMoment}</span></cite>
          </blockquote>
          
          <div class="result-quest">
            <div class="quest-tag">Suggested Action Step</div>
            <p>${matchedData.quest}</p>
          </div>
        </div>
      `;
      outputCard.classList.add("show");
      reflectBtn.disabled = false;
      
      triggerMascotAction("nod");
    });
  }

  function triggerMascotAction(action) {
    const mascot = document.querySelector(".pingu-svg");
    if (!mascot) return;
    
    mascot.classList.remove("nodding", "bouncing", "blinking");
    // Force reflow
    void mascot.offsetWidth;
    
    if (action === "nod") {
      mascot.classList.add("nodding");
    } else if (action === "bounce") {
      mascot.classList.add("bouncing");
    } else if (action === "blink") {
      mascot.classList.add("blinking");
    }
  }
});
