<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
  // Ctrl+K focus ô tìm kiếm
  document.addEventListener('keydown', e => {
    if (e.ctrlKey && e.key.toLowerCase() === 'k') {
      e.preventDefault();
      document.getElementById('searchInput').focus();
    }
  });

  // Đổi theme bằng data-bs-theme của Bootstrap 5.3
  const html = document.documentElement;
  const icon = document.querySelector('#themeToggle i');
  document.getElementById('themeToggle').addEventListener('click', () => {
    const dark = html.dataset.bsTheme === 'dark';
    html.dataset.bsTheme = dark ? 'light' : 'dark';
    icon.className = dark ? 'bi bi-moon' : 'bi bi-brightness-high';
  });
</script>

</body>
</html> 