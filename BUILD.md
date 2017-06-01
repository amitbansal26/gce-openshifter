# Build locally OpenShifter, populate the templates & install binary

```
go get github.com/osevg/openshifter
git checkout wip-fm9

go get github.com/Sirupsen/logrus
go get gopkg.in/yaml.v2
go get github.com/spf13/cobra
go get golang.org/x/crypto/ssh
go get github.com/mitchellh/gox
go get github.com/inconshreveable/mousetrap
go get github.com/jteeuwen/go-bindata/...
go get github.com/pkg/sftp

go generate
go install 
```