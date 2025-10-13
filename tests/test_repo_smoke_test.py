import os
import unittest

ROOT = os.path.dirname(os.path.dirname(__file__))


class RepoSmokeTests(unittest.TestCase):
    def test_scripts_exist(self):
        self.assertTrue(os.path.isfile(os.path.join(ROOT, 'script', 'install_env.sh')))
        self.assertTrue(os.path.isfile(os.path.join(ROOT, 'script', 'uninstall_env.sh')))
        self.assertTrue(os.path.isfile(os.path.join(ROOT, 'script', 'turing-smart-screen.service')))

    def test_readme_mentions_install_steps(self):
        with open(os.path.join(ROOT, 'README.md'), 'r', encoding='utf-8') as f:
            readme = f.read()
        self.assertIn('install_env.sh', readme)
        self.assertIn('uninstall_env.sh', readme)
        self.assertIn('venv', readme)

    def test_service_user_and_paths_are_template_like(self):
        svc_path = os.path.join(ROOT, 'script', 'turing-smart-screen.service')
        with open(svc_path, 'r', encoding='utf-8') as f:
            content = f.read()
        self.assertIn('User=', content)
        self.assertIn('WorkingDirectory=', content)
        self.assertIn('ExecStart=', content)
        # Ensure main.py is referenced (placeholder)
        self.assertIn('main.py', content)

    def test_install_script_generates_requirements(self):
        # We cannot execute system package managers here; just sanity‑check the pinned packages list appears in the script.
        with open(os.path.join(ROOT, 'script', 'install_env.sh'), 'r', encoding='utf-8') as f:
            install_sh = f.read()
        for pkg in [
            'pyserial', 'PyYAML', 'psutil', 'pystray', 'babel', 'ruamel.yaml', 'sv-ttk',
            'tkinter-tooltip', 'uptime', 'requests', 'ping3', 'pyinstaller', 'Pillow', 'GPUtil']:
            self.assertIn(pkg, install_sh)


if __name__ == '__main__':
    unittest.main()
