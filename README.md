# sample usage

```
$ gem install berkshelf
$ vagrant install vagrant-omnibus vagrant-berkshelf
$ vagrant up
$ vagrant ssh
> ldapsearch -D "cn=Manager,dc=my-domain,dc=com" -w secret -b "dc=my-domain,dc=com"
```

# recies

* openldap
* openldap::sample

# attributes

* openldap[rootdn]
* openldap[rootpw]
