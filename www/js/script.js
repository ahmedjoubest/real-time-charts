
function togglePanel() {
  var panel = document.getElementById('panel');
  var settingsBtn = document.getElementById('settings-btn');
  if (panel.style.display === 'none') {
    panel.style.display = 'block';
    settingsBtn.style.display = 'none';
  } else {
    panel.style.display = 'none';
    settingsBtn.style.display = 'block';
  }
}
    
function showPanel() {
  var panel = document.getElementById('panel');
  var settingsBtn = document.getElementById('settings-btn');
  panel.style.display = 'block';
  settingsBtn.style.display = 'none';
}