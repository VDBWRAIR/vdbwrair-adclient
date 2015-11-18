# Installs required packages
class adclient::install inherits adclient {
    ensure_packages($adclient::non_gui_packages)
}
