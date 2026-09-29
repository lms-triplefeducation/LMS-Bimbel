document.addEventListener("DOMContentLoaded", function () {
  const loginForm = document.getElementById("login-form");
  const loginPage = document.getElementById("login-page");
  const dashboardPage = document.getElementById("dashboard-page");
  const loginAlert = document.getElementById("login-alert");
  const btnLogin = document.getElementById("btn-login");
  const btnLogout = document.getElementById("btn-logout");

  // Cek apakah ada sesi tersimpan
  checkSession();

  // Handle Event Submit Login
  if (loginForm) {
    loginForm.addEventListener("submit", async function (e) {
      // PENTING: Cegah reload otomatis halaman
      e.preventDefault();

      hideAlert();

      const username = document.getElementById("username").value.trim();
      const password = document.getElementById("password").value.trim();
      const role = document.getElementById("role-select").value;

      if (!username || !password) {
        showAlert("Username dan Password tidak boleh kosong.");
        return;
      }

      // Tampilkan status loading
      btnLogin.disabled = true;
      btnLogin.innerHTML = `<span class="spinner-border spinner-border-sm me-2" role="status"></span>Memproses...`;

      try {
        // Jika API URL belum diatur, gunakan mode demo/lokal
        if (!CONFIG.API_URL || CONFIG.API_URL.includes("GANTI_DENGAN")) {
          console.warn("API_URL belum diatur. Menggunakan mode login lokal (Demo).");
          setTimeout(() => {
            const userData = { username, role, name: username };
            saveSession(userData);
            showDashboard(userData);
            btnLogin.disabled = false;
            btnLogin.innerHTML = `<i class="bi bi-box-arrow-in-right me-1"></i> Masuk`;
          }, 800);
          return;
        }

        // Request ke Backend Apps Script
        const response = await fetch(`${CONFIG.API_URL}?action=login`, {
          method: "POST",
          headers: { "Content-Type": "text/plain;charset=utf-8" },
          body: JSON.stringify({ username, password, role })
        });

        const result = await response.json();

        if (result.success || result.status === "success") {
          const userData = result.data || { username, role, name: username };
          saveSession(userData);
          showDashboard(userData);
        } else {
          showAlert(result.message || "Username atau Password salah.");
        }
      } catch (error) {
        console.error("Login Error:", error);
        showAlert("Gagal terhubung ke server Google Apps Script. Periksa konfigurasi API_URL.");
      } finally {
        btnLogin.disabled = false;
        btnLogin.innerHTML = `<i class="bi bi-box-arrow-in-right me-1"></i> Masuk`;
      }
    });
  }

  // Handle Logout
  if (btnLogout) {
    btnLogout.addEventListener("click", function () {
      localStorage.removeItem("lms_user_session");
      loginPage.classList.remove("hidden");
      dashboardPage.classList.add("hidden");
      document.getElementById("username").value = "";
      document.getElementById("password").value = "";
    });
  }

  function saveSession(data) {
    localStorage.setItem("lms_user_session", JSON.stringify(data));
  }

  function checkSession() {
    const session = localStorage.getItem("lms_user_session");
    if (session) {
      const userData = JSON.parse(session);
      showDashboard(userData);
    }
  }

  function showDashboard(userData) {
    loginPage.classList.add("hidden");
    dashboardPage.classList.remove("hidden");

    document.getElementById("user-welcome").innerText = `Selamat Datang, ${userData.name || userData.username}!`;
    document.getElementById("user-role-badge").innerText = `Peran / Role: ${userData.role || 'Siswa'}`;
  }

  function showAlert(message) {
    if (loginAlert) {
      loginAlert.innerText = message;
      loginAlert.classList.remove("hidden");
    }
  }

  function hideAlert() {
    if (loginAlert) {
      loginAlert.classList.add("hidden");
    }
  }
});
