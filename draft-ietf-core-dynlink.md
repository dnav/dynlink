---
title: "Dynamic Resource Linking for Constrained RESTful Environments"
abbrev: Dynamic Resource Linking for CoRE
docname: draft-ietf-core-dynlink-latest
date: 2016-10-19
category: info

ipr: trust200902
area: art
workgroup: CoRE Working Group
keyword: [Internet-Draft, CoRE, CoAP, Link Binding, Observe]

stand_alone: yes
pi: [toc, sortrefs, symrefs]

author:
- ins: Z. Shelby
  name: Zach Shelby
  organization: ARM
  street: 150 Rose Orchard
  city: San Jose
  code: 95134
  country: FINLAND
  phone: "+1-408-203-9434"
  email: zach.shelby@arm.com
- ins: Z.V. Vial
  name: Matthieu Vial
  organization: Schneider-Electric
  street: '' 
  city: Grenoble
  code: ''
  country: FRANCE
  phone: "+33 (0)47657 6522"
  email: matthieu.vial@schneider-electric.com
- ins: M. Koster
  name: Michael Koster
  organization: SmartThings
  street: 665 Clyde Avenue
  city: Mountain View
  code: 94043
  country: USA
  email: michael.koster@smartthings.com
- ins: C. Groves
  name: Christian Groves
  organization: Huawei
  street: '' 
  city: ''
  code: ''
  country: Australia
  email: Christian.Groves@nteczone.com

normative:
  RFC2119:
  RFC5988:
  RFC6690:

  
informative:
  RFC7252:
  RFC7641:
  

--- abstract

 For CoAP {{RFC7252}} Dynamic linking of state updates between resources, either on an endpoint or between endpoints, is defined with the concept of Link Bindings. This document defines conditional observation attributes that work with Link Bindings or with simple CoAP Observe {{RFC7641}}.

--- middle

Introduction        {#introduction}
============

IETF Standards for machine to machine communication in constrained environments describe a REST protocol and a set of related information standards that may be used to represent machine data and machine metadata in REST interfaces. CoRE Link-format is a standard for doing Web Linking {{RFC5988}} in constrained environments. 

This document introduces the concept of a Link Binding, which defines a new link relation type to create a dynamic link between resources over which to exchange state updates. Specifically, a Link Binding is a link for binding the state of 2 resources together such that updates to one are sent over the link to the other. CoRE Link Format representations are used to configure, inspect, and maintain Link Bindings. This document additionally defines a set of conditional Observe Attributes for use with Link Bindings and with the standalone CoRE Observe {{RFC7641}} method.

Editor's note: This initial version is based on the text of I.D.ietf-core-interfaces-04. Further work is needed around link bindings and extending the obeserve attributes with another use
case that requires 3 new optional attributes.



Terminology     {#terminology}
===========
The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",   "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in {{RFC2119}}.

This specification requires readers to be familiar with all the terms and concepts that are discussed in {{RFC5988}} and {{RFC6690}}.  This specification makes use of the following additional terminology:

Link Binding:
: A unidirectional logical link between a source resource and a destination resource, over which state information is synchronized.

Link Bindings and Observe Attributes        {#bindings}
====================================
In a M2M RESTful environment, endpoints may directly exchange the content of their resources to operate the distributed system. For example, a light switch may supply on-off control information that may be sent directly to a light resource for on-off control. Beforehand, a configuration phase is necessary to determine how the resources of the different endpoints are related to each other. This can be done either automatically using discovery mechanisms or by means of human intervention and a so-called commissioning tool. In this document the abstract relationship between two resources is called a link Binding. The configuration phase necessitates the exchange of binding information so a format recognized by all CoRE endpoints is essential. This document defines a format based on the CoRE Link-Format to represent binding information along with the rules to define a binding method which is a specialized relationship between two resources. The purpose of a binding is to synchronize the content between a source resource and a destination resource. The destination resource MAY be a group resource if the authority component of the destination URI contains a group address (either a multicast address or a name that resolves to a multicast address). Since a binding is unidirectional, the binding entry defining a relationship is present only on one endpoint. The binding entry may be located either on the source or the destination endpoint depending on the binding method. The following table gives a summary of the binding methods described in more detail in {{binding_methods}}

 | Name    | Identifier  | Location    | Method        |
 | Polling | poll        | Destination | GET           |
 | Observe | obs         | Destination | GET + Observe |
 | Push    | push        | Source      | PUT           |
{: #bindsummary title="Binding Method Summary"}

Format    {#binding_format}
------
Since Binding involves the creation of a link between two resources, Web Linking and the CoRE Link-Format are a natural way to represent binding information. This involves the creation of a new relation type, purposely named "boundto". In a Web link with this relation type, the target URI contains the location of the source resource and the context URI points to the destination resource. The Web link attributes allow a fine-grained control of the type of synchronization exchange along with the conditions that trigger an update. This specification defines the attributes below:

| Attribute         | Parameter | Value            |
| Binding method    | bind      | xsd:string       |
| Minimum Period (s)| pmin      | xsd:integer (>0) |
| Maximum Period (s)| pmax      | xsd:integer (>0) |
| Change Step       | st        | xsd:decimal (>0) |
| Greater Than      | gt        | xsd:decimal      |
| Less Than         | lt        | xsd:decimal      |
{: #weblinkattributes title="Binding Attributes Summary"}
 
Bind Method: 
: This is the identifier of a binding method which defines the rules to synchronize the destination resource. This attribute is mandatory.

Minimum Period:
: When present, the minimum period indicates the minimum time to wait (in seconds) before sending a new synchronization message (even if it has changed). In the absence of this parameter, the minimum period is up to the notifier.

Maximum Period:
: When present, the maximum period indicates the maximum time in seconds between two consecutive state synchronization messages (regardless if it has changed). In the absence of this parameter, the maximum period is up to the notifier. The maximum period MUST be greater than the minimum period parameter (if present).

Change Step: 
: When present, the change step indicates how much the value of a resource SHOULD change before sending a new notification (compared to the value of the last notification). This parameter has lower priority than the period parameters, thus even if the change step has been fulfilled, the time since the last notification SHOULD be between pmin and pmax.

Greater Than: 
: When present, Greater Than indicates the upper limit value the resource value SHOULD cross before sending a new notification. This parameter has lower priority than the period parameters, thus even if the Greater Than limit has been crossed, the time since the last notification SHOULD be between pmin and pmax.

Less Than: 
: When present, Less Than indicates the lower limit value the resource value SHOULD cross before sending a new notification. This parameter has lower priority than the period parameters, thus even if the Less Than limit has been crossed, the time since the last notification SHOULD be between pmin and pmax.

Binding Methods    {#binding_methods}
---------------
A binding method defines the rules to generate the web-transfer exchanges that will effectively send content from the source resource to the destination resource. The description of a binding method must define the following aspects:

Identifier: 
: This is value of the &quot;bind&quot; attribute used to identify the method.

Location: 
: This information indicates whether the binding entry is stored on the source or on the destination endpoint.

REST Method: 
: This is the REST method used in the Request/Response exchanges.

Conditions: 
: A binding method definition must state how the condition attributes of the abstract binding definition are actually used in this specialized binding.

This specification supports 3 binding methods described below:

Polling: 
: The Polling method consists of sending periodic GET requests from the destination endpoint to the source resource and copying the content to the destination resource. The binding entry for this method MUST be stored on the destination endpoint. The destination endpoint MUST ensure that the polling frequency does not exceed the limits defined by the pmin and pmax attributes of the binding entry. The copying process MAY filter out content from the GET requests using value-based conditions (e.g Change Step, Less Than, Greater Than).

Observe: 
: The Observe method creates an observation relationship between the destination endpoint and the source resource. On each notification the content from the source resource is copied to the destination resource. The creation of the observation relationship requires the CoAP Observation mechanism {{RFC7641}} hence this method is only permitted when the resources are made available over CoAP. The binding entry for this method MUST be stored on the destination endpoint. The binding conditions are mapped as query string parameters (see {{observation}}).

Push: 
: When the Push method is assigned to a binding, the source endpoint sends PUT requests to the destination resource when the binding condition attributes are satisfied for the source resource. The source endpoint MUST only send a notification request if the binding conditions are met. The binding entry for this method MUST be stored on the source endpoint.

Binding Table     {#binding_table}
-------------
The binding table is a special resource that gives access to the bindings on a endpoint. A binding table resource MUST support the Binding interface defined in {{binding_interface}}. A profile SHOULD allow only one resource table per endpoint.

Resource Observation Attributes      {#observation}
-------------------------------
When resource interfaces following this specification are made available over CoAP, the CoAP Observation mechanism {{RFC7641}} MAY be used to observe any changes in a resource, and receive asynchronous notifications as a result. In addition, a set of query string parameters are defined here to allow a client to control how often a client is interested in receiving notifications and how much a resource value should change for the new representation to be interesting. These query parameters are described in the following table. A resource using an interface description defined in this specification and marked as Observable in its link description SHOULD support these observation parameters. The Change Step parameter can only be supported on resources with an atomic numeric value.

These query parameters MUST be treated as resources that are read using GET and updated using PUT, and MUST NOT be included in the Observe request. Multiple parameters MAY be updated at the same time by including the values in the query string of a PUT. Before being updated, these parameters have no default value.

| Resource       | Parameter        | Data Format      |
| Minimum Period | /{resource}?pmin | xsd:integer (>0) |
| Maximum Period | /{resource}?pmax | xsd:integer (>0) |
| Change Step    | /{resource}?st   | xsd:decimal (>0) |
| Less Than      | /{resource}?lt   | xsd:decimal      |
| Greater Than   | /{resource}?gt   | xsd:decimal      |
{: #resobsattr title="Resource Observation Attribute Summary"}

Minimum Period: 
: When present, the minimum period indicates the minimum time to wait (in seconds) before sending a new synchronization message (even if it has changed). In the absence of this parameter, the minimum period is up to the notifier.

Maximum Period: 
: When present, the maximum period indicates the maximum time in seconds between two consecutive state synchronization messages (regardless if it has changed). In the absence of this parameter, the maximum period is up to the notifier. The maximum period MUST be greater than the minimum period parameter (if present).

Change Step: 
: When present, the change step indicates how much the value of a resource SHOULD change before sending a new notification (compared to the value of the last notification). This parameter has lower priority than the period parameters, thus even if the change step has been fulfilled, the time since the last notification SHOULD be between pmin and pmax.

Greater Than: 
: When present, Greater Than indicates the upper limit value the resource value SHOULD cross before sending a new notification. This parameter has lower priority than the period parameters, thus even if the Greater Than limit has been crossed, the time since the last notification SHOULD be between pmin and pmax.

Less Than: 
: When present, Less Than indicates the lower limit value the resource value SHOULD cross before sending a new notification. This parameter has lower priority than the period parameters, thus even if the Less Than limit has been crossed, the time since the last notification SHOULD be between pmin and pmax.

Interface Descriptions    {#interfaces}
======================
This section defines REST interfaces for Binding table resources. The interface supports the link-format type.

The if= column defines the Interface Description (if=) attribute value to be used in the CoRE Link Format for a resource conforming to that interface. When this value appears in the if= attribute of a link, the resource MUST support the corresponding REST interface described in this section. The resource MAY support additional functionality, which is out of scope for this specification. Although this interface descriptions is intended to be used with the CoRE Link Format, it is applicable for use in any REST interface definition.

The Methods column defines the methods supported by that interface, which are described in more detail below. 

| Interface | if=      | Methods           | Content-Formats |
| Binding   | core.bnd | GET, POST, DELETE | link-format     |
{: #intdesc title="Inteface Description"}

Binding     {#binding_interface}
-------
The Binding interface is used to manipulate a binding table. A request with a POST method and a content format of application/link-format simply appends new bindings to the table. All links in the payload MUST have a relation type &quot;boundTo&quot;. A GET request simply returns the current state of a binding table whereas a DELETE request empties the table.

The following example shows requests for adding, retrieving and deleting bindings in a binding table.

~~~~
Req: POST /bnd/ (Content-Format: application/link-format)
<coap://sensor.example.com/s/light>;
  rel="boundto";anchor="/a/light";bind="obs";pmin="10";pmax="60"
Res: 2.04 Changed 

Req: GET /bnd/
Res: 2.05 Content (application/link-format)
<coap://sensor.example.com/s/light>;
  rel="boundto";anchor="/a/light";bind="obs";pmin="10";pmax="60"

Req: DELETE /bnd/
Res: 2.04 Changed
~~~~
{: #figbindexp title="Binding Interface Example"}

 
Security Considerations   {#Security}
=======================
An implementation of a client needs to be prepared to deal with responses to a request that differ from what is specified in this document. A server implementing what the client thinks is a resource with one of these interface descriptions could return malformed representations and response codes either by accident or maliciously. A server sending maliciously malformed responses could attempt to take advantage of a poorly implemented client for example to crash the node or perform denial of service. 


IANA Considerations
===================
The "binding" interface description types requires registration

The new link relations type "boundto" requires registration.

Acknowledgements
================
Acknowledgement is given to colleagues from the SENSEI project who were critical in the initial development of the well-known REST interface concept, to members of the IPSO Alliance where further requirements for interface types have been discussed, and to Szymon Sasin, Cedric Chauvenet, Daniel Gavelle and Carsten Bormann who have provided useful discussion and input to the concepts in this document.

Changelog
=========

draft-ietf-core-dynlink Initial Version 00:

* This is a copy of draft-groves-core-dynlink-00

draft-groves-core-dynlink Draft Initial Version 00:

* This initial version is based on the text regarding the dynamic linking functionality in I.D.ietf-core-interfaces-05.

* The WADL description has been dropped in favour of a thorough textual description of the REST API.




