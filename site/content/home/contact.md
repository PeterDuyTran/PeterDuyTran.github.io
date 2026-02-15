---
title: "Contact"
weight: 30
---

<div class="contact-grid">
  <div class="contact-info">
    <div class="contact-item">
      <i class="fas fa-phone"></i>
      <a href="tel:+84000000000">+84 000 000 000</a>
    </div>
    <div class="contact-item">
      <i class="fab fa-linkedin"></i>
      <a href="https://linkedin.com/in/tnqduy" target="_blank" rel="noopener">linkedin.com/in/tnqduy</a>
    </div>
    <div class="contact-item">
      <i class="fas fa-envelope"></i>
      <a href="mailto:duytran@example.com">duytran@example.com</a>
    </div>
    <div class="contact-item">
      <i class="fab fa-github"></i>
      <a href="https://github.com/tnqduy" target="_blank" rel="noopener">github.com/tnqduy</a>
    </div>
  </div>
  <div class="contact-cv">
    <a href="/cv/DuyTran_CV.pdf" class="cv-button" download>
      <i class="fas fa-file-download"></i> Download CV
    </a>
  </div>
</div>

<style>
.contact-grid {
  max-width: 500px;
  margin: 2rem auto;
  text-align: left;
}
.contact-info {
  display: flex;
  flex-direction: column;
  gap: 1.2rem;
  margin-bottom: 2rem;
}
.contact-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  font-size: 1.05rem;
}
.contact-item i {
  width: 24px;
  text-align: center;
  color: #4fc3f7;
  font-size: 1.1rem;
}
.contact-item a {
  color: inherit;
  text-decoration: none;
  transition: color 0.2s ease;
}
.contact-item a:hover {
  color: #4fc3f7;
}
.contact-cv {
  text-align: center;
}
.cv-button {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.8rem 2rem;
  background: #4fc3f7;
  color: #1a1a2e;
  font-weight: 600;
  border-radius: 4px;
  text-decoration: none;
  transition: background 0.2s ease, transform 0.1s ease;
}
.cv-button:hover {
  background: #81d4fa;
  transform: translateY(-1px);
}
.cv-button i {
  font-size: 1.1rem;
}
</style>
