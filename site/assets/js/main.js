/* Dynamic typing animation steps */
(function() {
    document.querySelectorAll('.typing-text').forEach(function(el, i) {
        var len = el.textContent.trim().length;
        var duration = (len * 0.1).toFixed(1);
        if (i === 0) {
            el.style.animation = 'typing ' + duration + 's steps(' + len + ', end) forwards, blink-caret 0.6s step-end infinite, hide-caret 0s ' + duration + 's forwards';
        } else {
            var firstEl = document.querySelector('.typing-text');
            var firstLen = firstEl ? firstEl.textContent.trim().length : 18;
            var delay = (firstLen * 0.1).toFixed(1);
            el.style.animation = 'show-caret 0s ' + delay + 's forwards, typing ' + duration + 's steps(' + len + ', end) ' + delay + 's forwards, blink-caret 0.6s step-end ' + delay + 's infinite';
        }
    });
})();

/* Tab navigation */
(function() {
    var tabs = document.querySelectorAll('.tab-link');
    var panels = document.querySelectorAll('.tab-panel');
    var indicator = document.querySelector('.tab-indicator');

    function updateIndicator(tab) {
        if (!indicator) return;
        var nav = document.querySelector('.tabs-nav');
        var navRect = nav.getBoundingClientRect();
        var tabRect = tab.getBoundingClientRect();
        indicator.style.left = (tabRect.left - navRect.left) + 'px';
        indicator.style.width = tabRect.width + 'px';
    }

    function activateTab(tabId, pushState) {
        tabs.forEach(function(t) { t.classList.remove('is-active'); });
        panels.forEach(function(p) { p.classList.remove('is-active'); });

        var activeTab = document.querySelector('.tab-link[data-tab="' + tabId + '"]');
        var activePanel = document.querySelector('.tab-panel[data-panel="' + tabId + '"]');

        if (activeTab) {
            activeTab.classList.add('is-active');
            updateIndicator(activeTab);
        }
        if (activePanel) {
            activePanel.classList.add('is-active');
        }

        if (pushState) {
            history.replaceState(null, '', '#' + tabId);
        }
    }

    tabs.forEach(function(tab) {
        tab.addEventListener('click', function(e) {
            e.preventDefault();
            activateTab(this.getAttribute('data-tab'), true);
            var sectionTabs = document.querySelector('.section-tabs');
            if (sectionTabs) {
                var rect = sectionTabs.getBoundingClientRect();
                if (rect.top < 0 || rect.top > 0) {
                    sectionTabs.scrollIntoView({ behavior: 'instant', block: 'start' });
                }
            }
        });
    });

    function activateFromHash() {
        var hash = window.location.hash.replace('#', '');
        if (hash && document.querySelector('.tab-panel[data-panel="' + hash + '"]')) {
            activateTab(hash, false);
        } else if (tabs.length > 0) {
            activateTab(tabs[0].getAttribute('data-tab'), false);
        }
    }

    window.addEventListener('hashchange', activateFromHash);

    requestAnimationFrame(function() {
        activateFromHash();
    });

    var arrow = document.getElementById('scroll-arrow');
    if (arrow) {
        arrow.addEventListener('click', function(e) {
            e.preventDefault();
            var target = document.getElementById('content-anchor');
            if (target) {
                target.scrollIntoView({ behavior: 'smooth' });
            }
        });
    }

    window.addEventListener('resize', function() {
        var active = document.querySelector('.tab-link.is-active');
        if (active) updateIndicator(active);
    });
})();

/* Project showcase */
(function() {
    var items = document.querySelectorAll('.project-item');
    var contents = document.querySelectorAll('.project-content');
    var indicator = document.querySelector('.connector-indicator');
    var showcase = document.querySelector('.project-showcase');

    function updateIndicator(item) {
        if (!indicator || !showcase) return;
        var showcaseRect = showcase.getBoundingClientRect();
        var itemRect = item.getBoundingClientRect();
        var top = itemRect.top - showcaseRect.top;
        var height = itemRect.height;
        indicator.style.top = top + 'px';
        indicator.style.height = height + 'px';
    }

    var firstActive = document.querySelector('.project-item.is-active');
    if (firstActive) {
        requestAnimationFrame(function() {
            updateIndicator(firstActive);
        });
    }

    items.forEach(function(item) {
        item.addEventListener('mouseenter', function() {
            var idx = this.getAttribute('data-project');

            items.forEach(function(i) { i.classList.remove('is-active'); });
            contents.forEach(function(c) { c.classList.remove('is-active'); });

            this.classList.add('is-active');
            var target = document.querySelector('[data-project-content="' + idx + '"]');
            if (target) target.classList.add('is-active');

            updateIndicator(this);
        });
    });
})();
