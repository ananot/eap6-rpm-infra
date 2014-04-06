%define product_version 2.0.1

%define product_name jboss-webserver
%define product_home /usr/local/%{product_name}-%{product_version}

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


Requires(pre): krb5-workstation, mod_auth_kerb, elinks, apr-devel, apr-util-devel, java-1.6.0-openjdk


%pre
%install
%post
%clean
exit 0

%description

%files
#%defattr(-,%{username},%{group})
%{product_home}


%doc


%changelog

