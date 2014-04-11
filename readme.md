#Installation instructions for maaslin in a galaxy environment.

For General infomation about maaslin please refer to:
```
https://bitbucket.org/biobakery/biobakery/wiki/maaslin
```


These instructions require the Mercurial versioning system, galaxy, and an internet connection.

In the  "galaxy-dist/tools" directory install maaslin by typing in a terminal:
```
hg clone https://bitbucket.org/biobakery/maaslin
```
Update member tool_conf.xml  in the galaxy directory adding the following: 
```
  <section name="maaslin" id="maaslin">
    <tool file="maaslin/galaxy/maaslin_input.xml"/>
    <tool file="maaslin/galaxy/maaslin.xml"/>
  </section>
```
Update member datatypes_conf.xml  in the galaxy directory adding the following:
```
	<datatype extension="maaslin" type="galaxy.datatypes.data:Text" subclass="true" display_in_upload="true"/>
```

Copy members Figure1-Overview.png and Maaslin_Output.png  to /galaxy/static/images 

 Recycle galaxy

