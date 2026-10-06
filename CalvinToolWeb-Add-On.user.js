// ==UserScript==
// @name         CalvinToolWeb-Add-On
// @namespace    CalvinToolWeb
// @version      [20261006A]
// @description  點左側藍色 CalvinToolWeb 圖示時，開新分頁到使用說明
// @match        http://127.0.0.1:8765/*
// @match        http://localhost:8765/*
// @grant        GM_openInTab
// @run-at       document-idle
// ==/UserScript==

(function () {
  'use strict';

  const MANUAL_URL = 'file:///D:/Git/CalvinToolWeb/%E4%BD%BF%E7%94%A8%E8%AA%AA%E6%98%8E.html';
  const LOGO_SELECTOR = 'div.grid.size-11.place-items-center.rounded-2xl.bg-primary';

  const style = document.createElement('style');
  style.textContent = LOGO_SELECTOR + ' { cursor: pointer; }';
  document.documentElement.appendChild(style);

  document.addEventListener('click', (event) => {
    const logo = event.target.closest(LOGO_SELECTOR);
    if (!logo) {
      return;
    }
    const row = logo.parentElement;
    if (!row || !row.textContent.includes('PC52Q')) {
      return;
    }
    event.preventDefault();
    event.stopPropagation();
    GM_openInTab(MANUAL_URL, { active: true, insert: true, setParent: true });
  }, true);
})();
