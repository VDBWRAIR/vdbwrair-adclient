# Installs required packages
class adclient::install inherits adclient {
    ensure_packages($non_gui_packages)
    if $use_smartcard {
        ensure_packages($gui_packages)
    }
}
