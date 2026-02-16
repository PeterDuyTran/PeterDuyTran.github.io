---
title: "Contact"
weight: 30
---

<div class="contact-grid">
  <div class="contact-info">
    <div class="contact-item">
      <i class="fas fa-phone"></i>
      <a class="contact-obf" data-p1="+84 036" data-p2="764" data-p3="9934" data-type="tel">Loading...</a>
    </div>
    <div class="contact-item">
      <i class="fas fa-envelope"></i>
      <a class="contact-obf" data-p1="peter.duytran95" data-p2="gmail" data-p3="com" data-type="email">Loading...</a>
    </div>
    <div class="contact-item">
      <i class="fab fa-linkedin"></i>
      <a href="https://www.linkedin.com/in/duy-tran-peter-775475167/" target="_blank" rel="noopener">LinkedIn</a>
    </div>
  </div>
  <div class="contact-cv">
    <a href="/cv/DuyTran_CV.pdf" class="cv-button" download>
      <i class="fas fa-file-download"></i> Download CV
    </a>
  </div>
</div>

<script>
document.querySelectorAll('.contact-obf').forEach(function(el) {
  var type = el.dataset.type;
  if (type === 'email') {
    var addr = el.dataset.p1 + '@' + el.dataset.p2 + '.' + el.dataset.p3;
    el.href = 'mailto:' + addr;
    el.textContent = addr;
  } else if (type === 'tel') {
    var num = el.dataset.p1 + el.dataset.p2 + el.dataset.p3;
    el.href = 'tel:' + num.replace(/\s/g, '');
    el.textContent = num;
  }
});
</script>
