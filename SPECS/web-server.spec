%define product_version 2.0.1

%define product_name jboss-webserver
%define product_home /usr/local/java/%{product_name}-%{product_version}

%define username %{product_name}
%define group %{product_name}

Name:	    %{product_name}
Version:	%{product_version}
Release:	1%{?dist}
Summary:    Set up instance JBoss Enterprise Web Server %{product_version}

Group:      Administration
License:	GPL
URL:        http://access.redhat.com/

Packager:   Romain Pelisse
BuildArch:  x86_64

Source0:    %{product_name}-%{product_version}.tgz
Source1:    httpd-init-script.tgz


Requires(pre): krb5-workstation, elinks, apr-devel, apr-util-devel, java-1.6.0-openjdk

%prep
%setup -q
%setup -q -b 1 -D -T

%pre
mkdir -p %{product_home}
getent group %{group} > /dev/null || groupadd -r %{group}
getent passwd %{username}  > /dev/null || \
    useradd -r -g %{group} -d %{product_home} -s /sbin/nologin \
    -c "JBoss Web Server (httpd) user account" %{username}


%install
mkdir -p %{buildroot}/%{product_home}
cp -rp %{_builddir}/%{name}-%{version}/* %{buildroot}/%{product_home}
mkdir -p %{buildroot}//etc/init.d/
cp -rp %{_builddir}/httpd-init-script/httpd %{buildroot}/etc/init.d/httpd
rm -f %{buildroot}/%{product_home}/conf.d/ssl.conf

%post
mkdir -p %{product_home}/html
sed -i %{product_home}/conf/httpd.conf \
    -e "s;\(^Listen \).*$;\1 $(hostname):80;" \
    -e 's;\(ServerRoot "\).*$;\1%{product_home}";' \
    -e 's;\(DocumentRoot "\).*$;\1%{product_home}/html";'

exit 0

%description

%files
%defattr(-,%{username},%{group})
%{product_home}
%defattr(-,root,root)
/etc/init.d/httpd

%doc


%changelog

