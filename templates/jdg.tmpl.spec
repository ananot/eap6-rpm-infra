%define jdg_version XXX

%define jdg_home /opt/jboss/jboss-datagrid-%{jdg_version}

%define username XXX
%define group XXX

Name:	    jdg
Version:	%{jdg_version}
Release:	0%{?dist}
Summary:    Packaging of Red Hat JBoss Data Grid, install required binary files.

Group:      Administration
License:	GPL
URL:        http://access.redhat.com/

Source0:    %{name}-%{jdg_version}.tgz

Patch0:     jboss-as-standalone.sh.patch
Patch1:     add-node-default-jvm-settings.patch

Packager:   Romain Pelisse
BuildArch:  noarch

Requires(pre): java

%prep
%setup -q
%patch0 -p1
%patch1 -p1

%pre
mkdir -p %{jdg_home}
getent group %{group} > /dev/null || groupadd -r %{group}
getent passwd %{username}  > /dev/null || \
    useradd -r -g %{group} -d %{jdg_home} -s /sbin/nologin \
    -c "JBoss Data Grid (JDG) user account" %{username}

%install
mkdir -p %{buildroot}/%{jdg_home}
cp -rp %{_builddir}/%{name}-%{version}/* %{buildroot}/%{jdg_home}

# add other patches for JDG, coming from Red Hat CSP, if needed, here...

%description

%files
%defattr(-,%{username},%{group})
%{jdg_home}

%doc


%changelog

