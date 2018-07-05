#!/bin/bash
#
#------ github updates --------

## update the QRL repo
cd ${HOME}/repo/qrl/
git pull

## update the QRL/integration_tests repo
cd ${HOME}/repo/integration_tests/
git pull

## update the repo/api.theqrl.org repo
cd ${HOME}/repo/api.theqrl.org/
git pull

## Move the proto file to our working directory
rsync -azPv ${HOME}/repo/qrl/src/qrl/protos/*.proto ${HOME}/repo/api.theqrl.org/_QRL/proto/
echo "Moved proto Files"
## Move the test.js file to our working directory
rsync -azPv ${HOME}/repo/integration_tests/tests/js/* ${HOME}/repo/api.theqrl.org/_QRL/tests/
echo "Moved test Files"

## Generate the docs from the .proto files using protoc-gen-doc
docker run --rm -v ${HOME}/repo/api.theqrl.org/_QRL/doc:/out -v ${HOME}/repo/api.theqrl.org/_QRL/proto/:/protos   pseudomuto/protoc-gen-doc --doc_opt=markdown,docs.md
#docker run --rm -v ${HOME}/repo/api.theqrl.org/_QRL/doc:/out -v ${HOME}/repo/api.theqrl.org/_QRL/proto/:/protos   pseudomuto/protoc-gen-doc --doc_opt=json,docs.json
#docker run --rm -v ${HOME}/repo/api.theqrl.org/_QRL/doc:/out -v ${HOME}/repo/api.theqrl.org/_QRL/proto/:/protos   pseudomuto/protoc-gen-doc --doc_opt=html,docs.html
#docker run --rm -v ${HOME}/repo/api.theqrl.org/_QRL/doc:/out -v ${HOME}/repo/api.theqrl.org/_QRL/proto/:/protos   pseudomuto/protoc-gen-doc --doc_opt=docbook,docs.xml
echo "Proto-Doc-Gen Ran file located at /repo/api.theqrl.org/_QRL/proto/"
echo ""
### Pull out any ### to <a name in the docs.md file and strip the <a name> tag

#sed -n '/###/,/a name/p' ${HOME}/manualAPI/examples/doc/docs.md > ${HOME}/manualAPI/examples/doc/out.txt

echo " change ### to ## and ## to #"
sed -i -e 's/##/#/g' ${HOME}/repo/api.theqrl.org/_QRL/doc/docs.md

echo ""
echo "strip everything before # qrl.proto "
sed '/# qrl.proto/,$!d' ${HOME}/repo/api.theqrl.org/_QRL/doc/docs.md > ${HOME}/repo/api.theqrl.org/_QRL/doc/out1.txt 
echo ""
echo " Add blank line to beginning of file"
sed -s -i '1i\\' ${HOME}/repo/api.theqrl.org/_QRL/doc/out1.txt

#echo "Remove the a name tag, #Table , <p> and #Prot from file"
#grep -vE "(<a name|# Table|<p|# Prot)" ${HOME}/repo/api.theqrl.org/_QRL/doc/out1.txt > ${HOME}/repo/api.theqrl.org/_QRL/doc/out2.txt

## converg front matter and API docs file
cat ${HOME}/repo/api.theqrl.org/front.txt ${HOME}/repo/api.theqrl.org/_QRL/doc/out1.txt > ${HOME}/repo/api.theqrl.org/_QRL/doc/QRL_index.html.md


### copy the index.html.md file we created into the root buld dir for slate
cp ${HOME}/repo/api.theqrl.org/_QRL/doc/QRL_index.html.md ${HOME}/repo/api.theqrl.org/_QRL/

## Push the docs to the late directory
cd ${HOME}/repo/api.theqrl.org
git add .
git commit -m "AutoUpdating QRL_index.html.md, see the changes in the /_QRL/QRL_index.html.md file"
git push

## Move the index.html.md file into the build dir
rsync -azPv ${HOME}/repo/api.theqrl.org/_QRL/index.html.md ${HOME}/repo/api.theqrl.org/source/


## Build the site
cd ${HOME}/repo/api.theqrl.org/
bundle install
## Bundle the slate site up into static files
bundle exec middleman build --clean 

cp -r ${HOME}/repo/api.theqrl.org/build/* ${HOME}/manual_site

## Move the site into the webroot and assign permissions
## Se webRootMove.sh
