# 🔥 Maester

**Monitor your Microsoft 365 tenant's security configuration using Maester!**

Maester is a **PowerShell-based test automation framework** designed to help you monitor and maintain the security configuration of your Microsoft 365 environment.

To learn more about Maester and to get started, visit [Maester.dev](https://maester.dev).

[![PSGallery Version](https://img.shields.io/powershellgallery/v/maester.svg?style=flat&logo=powershell&label=PSGallery%20Version)](https://www.powershellgallery.com/packages/maester) [![PSGallery Downloads](https://img.shields.io/powershellgallery/dt/maester.svg?style=flat&logo=powershell&label=PSGallery%20Downloads)](https://www.powershellgallery.com/packages/maester)

---

## Key Features

- **Automated Testing**: Maester provides a comprehensive set of automated tests to ensure the security of your Microsoft 365 setup.
- **Customizable**: Tailor Maester to your specific needs by adding custom Pester tests.
- **More to come...**
---

## Getting Started

### Installation

```powershell
Install-Module -Name Maester -Scope CurrentUser
```

## Running Maester

To run the tests in this folder run the following PowerShell commands. To learn more see [maester.dev](https://maester.dev).

```powershell
Connect-Maester
Invoke-Maester
```

### Running Maester in a National Cloud Environment

An optional parameter, `-Environment`, can be utilized on `Connect-Maester` to specify the name of the national cloud environment to connect to. By default global cloud is used.

Allowed values include:

- Global (default, if parameter is not specified)
- China
- Germany
- USGov
- USGovDOD

```powershell
Connect-Maester -Environment USGov
```


## Keeping your Maester tests up to date

The Maester team will add new tests over time. To get the latest updates, use the commands below to update this folder with the latest tests.

- Update the `Maester` PowerShell module to the latest version and load it.
- Run `Update-MaesterTests`.

```powershell
Update-Module Maester -Force
Import-Module Maester
Update-MaesterTests
```
