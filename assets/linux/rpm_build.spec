# This spec file expects _version, _build_date, _commit_hash, and _commit_number to be defined via rpmbuild --define
%{!?_version: %define _version 1.0.0}

Name:           piliplus
Version:        %{_version}
Release:        1%{?dist}
Summary:        PiliPlus Linux Version
License:        GPLv3+
Source0:        piliplus-%{_version}.tar.gz
# rpmbuild 无法识别 apt 安装的工具，故移除 BuildRequires。
# 构建所需的 chrpath, patchelf 已在 CI 脚本中通过 apt 预装。
# BuildRequires:  chrpath
Requires:       desktop-file-utils, hicolor-icon-theme

%description
使用 Flutter 开发的 BiliBili 第三方客户端

%prep
%setup -q -n piliplus-%{_version}

%build

%install
mkdir -p %{buildroot}/opt/PiliPlus
cp -r bundle/* %{buildroot}/opt/PiliPlus/

# 二进制权限与命令行入口
chmod 755 %{buildroot}/opt/PiliPlus/piliplus
find %{buildroot}/opt/PiliPlus/lib -name "*.so" -exec chmod 755 {} \;
find %{buildroot}/opt/PiliPlus -type f -executable -exec chrpath --delete {} \; 2>/dev/null || :
mkdir -p %{buildroot}/usr/bin
ln -sf ../../opt/PiliPlus/piliplus %{buildroot}/usr/bin/piliplus

# 桌面集成
mkdir -p %{buildroot}/usr/share/applications
install -m 644 assets/com.example.piliplus.desktop %{buildroot}/usr/share/applications/com.example.piliplus.desktop

mkdir -p %{buildroot}/usr/share/icons/hicolor/512x512/apps
install -m 644 assets/piliplus.png %{buildroot}/usr/share/icons/hicolor/512x512/apps/piliplus.png

# 去除调试符号
find %{buildroot}/opt/PiliPlus -type f \( -name "*.so" -o -name "piliplus" \) -exec strip --strip-unneeded {} \; 2>/dev/null || :

%post
update-desktop-database -q || true
gtk-update-icon-cache -q -t -f %{_datadir}/icons/hicolor || true

%postun
update-desktop-database -q || true
gtk-update-icon-cache -q -t -f %{_datadir}/icons/hicolor || true

%files
%dir /opt/PiliPlus
/opt/PiliPlus
%{_bindir}/piliplus
%{_datadir}/applications/com.example.piliplus.desktop
%{_datadir}/icons/hicolor/512x512/apps/piliplus.png

%changelog
* %{_build_date} GitHub Action - %{_version}
- Build from commit: %{_commit_hash}
- Commit Index: %{_commit_number}
