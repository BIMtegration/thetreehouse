(function(){
  // Mobile nav toggle
  const toggle = document.querySelector('.nav-toggle');
  const nav = document.querySelector('.site-nav');
  if(toggle && nav){
    toggle.addEventListener('click',()=>{
      const open = nav.style.display === 'flex';
      nav.style.display = open ? 'none' : 'flex';
      toggle.setAttribute('aria-expanded', String(!open));
    });
  }

  // Footer year
  const yearEl = document.getElementById('year');
  if(yearEl) yearEl.textContent = new Date().getFullYear();

  // Smooth scroll for same-page links
  document.querySelectorAll('a[href^="#"]').forEach(a=>{
    a.addEventListener('click', (e)=>{
      const id = a.getAttribute('href');
      if(!id || id === '#') return;
      const target = document.querySelector(id);
      if(target){
        e.preventDefault();
        target.scrollIntoView({behavior:'smooth'});
      }
    });
  });

})();
