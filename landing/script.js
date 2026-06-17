(function () {
  'use strict';

  // ── Theme ──────────────────────────────────────────────────────────────────
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

  // Sync icon state on load (FOUC script already applied data-theme)
  applyTheme(root.getAttribute('data-theme') || 'light');

  // ── Navbar scroll shadow ───────────────────────────────────────────────────
  const navbar = document.getElementById('navbar');
  window.addEventListener('scroll', () => {
    navbar?.classList.toggle('scrolled', window.scrollY > 10);
  }, { passive: true });

  // ── Mobile menu ────────────────────────────────────────────────────────────
  const hamburger = document.getElementById('hamburger');
  const navMobile = document.getElementById('navMobile');

  function closeMenu() {
    navMobile?.classList.remove('open');
    hamburger?.setAttribute('aria-expanded', 'false');
    navMobile?.setAttribute('aria-hidden', 'true');
  }

  hamburger?.addEventListener('click', function () {
    const open = navMobile.classList.toggle('open');
    hamburger.setAttribute('aria-expanded', String(open));
    navMobile.setAttribute('aria-hidden', String(!open));
  });

  document.addEventListener('click', e => {
    if (!navbar?.contains(e.target)) closeMenu();
  });

  document.addEventListener('keydown', e => {
    if (e.key === 'Escape') closeMenu();
  });
})();
