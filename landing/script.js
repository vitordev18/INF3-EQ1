(function () {
  'use strict';

  const root = document.documentElement;

  function applyTheme(t) {
    root.setAttribute('data-theme', t);
    const btn = document.getElementById('themeToggle');
    if (!btn) return;
    btn.textContent = t === 'dark' ? '☀' : '🌙';
    btn.setAttribute('aria-label', t === 'dark' ? 'Ativar tema claro' : 'Ativar tema escuro');
  }

  document.getElementById('themeToggle')?.addEventListener('click', function () {
    const next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
    localStorage.setItem('theme', next);
    applyTheme(next);
  });

  applyTheme(root.getAttribute('data-theme') || 'light');

  const navbar = document.getElementById('navbar');
  window.addEventListener(
    'scroll',
    () => {
      navbar?.classList.toggle('scrolled', window.scrollY > 10);
    },
    { passive: true },
  );

  const hamburger = document.getElementById('hamburger');
  const navMobile = document.getElementById('navMobile');

  function closeMenu() {
    navMobile?.classList.remove('open');
    hamburger?.setAttribute('aria-expanded', 'false');
    navMobile?.setAttribute('aria-hidden', 'true');
  }

  function openMenu() {
    navMobile?.classList.add('open');
    hamburger?.setAttribute('aria-expanded', 'true');
    navMobile?.setAttribute('aria-hidden', 'false');
  }

  hamburger?.addEventListener('click', function (e) {
    e.stopPropagation();
    if (navMobile?.classList.contains('open')) closeMenu();
    else openMenu();
  });

  document.querySelectorAll('[data-mobile-link]').forEach(a => {
    a.addEventListener('click', closeMenu);
  });

  document.addEventListener('click', e => {
    if (!navbar?.contains(e.target) && !navMobile?.contains(e.target)) closeMenu();
  });

  document.addEventListener('keydown', e => {
    if (e.key === 'Escape') closeMenu();
  });

  window.addEventListener('resize', () => {
    if (window.innerWidth > 980) closeMenu();
  });
})();
