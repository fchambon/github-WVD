
variable "sp_Id" {
  type    = string  
}

variable "sp_Secret" {
  type    = string  
}

variable "Offer" {
  type    = string  
}

variable "Publisher" {
  type    = string  
}

variable "Sku" {
  type    = string  
}

variable "image_location" {
  type    = string  
}

variable "image_Name" {
  type    = string  
}

variable "image_Rgname" {
  type    = string  
}

variable "Os" {
  type    = string  
}

variable "subscription_Id" {
  type    = string  
}

variable "tenant_Id" {
  type    = string  
}

variable "Share_Profils_location" {
  type    = string  
}

variable "Share_Profils_folder" {
  type    = string  
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }


source "azure-arm" "autogenerated_1" {
  client_id                         = "${var.sp_Id}"
  client_secret                     = "${var.sp_Secret}"
  communicator                      = "winrm"
  image_offer                       = "${var.Offer}"
  image_publisher                   = "${var.Publisher}"
  image_sku                         = "${var.Sku}"
  location                          = "${var.image_location}"
  managed_image_name                = "${var.image_Name}"
  managed_image_resource_group_name = "${var.image_Rgname}"
  os_type                           = "${var.Os}"
  subscription_id                   = "${var.subscription_Id}"
  tenant_id                         = "${var.tenant_Id}"
  vm_size                           = "Standard_D2s_v3"
  winrm_insecure                    = true
  winrm_timeout                     = "5m"
  winrm_use_ssl                     = true
  winrm_username                    = "packer"
}

build {
  sources = ["source.azure-arm.autogenerated_1"]

  provisioner "powershell" {
    inline = ["$ErrorActionPreference='Stop'", "Invoke-Expression ((New-Object -TypeName net.webclient).DownloadString('https://chocolatey.org/install.ps1'))", "& choco feature enable -n allowGlobalConfirmation", "Write-Host \"Chocolatey Installed.\""]
  }
  provisioner "powershell" {
    inline = ["$ErrorActionPreference='Stop'", "& choco install fslogix", "Write-Host \"fslogix Installed.\""]
  }
  provisioner "powershell" {
    inline = ["$ErrorActionPreference='Stop'", "& reg add HKLM\\SOFTWARE\\FSLogix\\Profiles", "Write-Host \"fslogix Profiles.\""]
  }
  provisioner "powershell" {
    inline = ["$ErrorActionPreference='Stop'", "& reg add HKLM\\SOFTWARE\\FSLogix\\Profiles /v Enabled /t REG_DWORD /d 0x00000001 ", "Write-Host \"fslogix Profiles Enabled.\""]
  }
  provisioner "powershell" {
    inline = ["$ErrorActionPreference='Stop'", "& reg add HKLM\\SOFTWARE\\FSLogix\\Profiles /v DeleteLocalProfileWhenVHDShouldApply /t REG_DWORD /d 0x00000001 ", "Write-Host \"fslogix Profiles DeleteLocalProfileWhenVHDShouldApply.\""]
  }
  provisioner "powershell" {
    inline = ["$ErrorActionPreference='Stop'", "& reg add HKLM\\SOFTWARE\\FSLogix\\Profiles /v VHDLocations /t REG_MULTI_SZ /d \\\\${var.Share_Profils_location}\\${var.Share_Profils_folder} ", "Write-Host \"fslogix Profiles VHDLocations .\""]
  }
  provisioner "powershell" {
    inline = ["$ErrorActionPreference='Stop'", "& choco install vlc", "Write-Host \"vlc Installed.\""]
  }
  provisioner "powershell" {
    inline = ["& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit", "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"]
  }
}
