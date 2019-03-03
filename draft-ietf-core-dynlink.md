---
title: "Dynamic Resource Linking for Constrained RESTful Environments"
abbrev: Dynamic Resource Linking for CoRE
docname: draft-ietf-core-dynlink-latest
date: 2019-3-2
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
  street: Kidekuja 2
  city: Vuokatti
  code: 88600
  country: FINLAND
  phone: "+358407796297"
  email: zach.shelby@arm.com
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
  organization: ''
  street: '' 
  city: ''
  code: ''
  country: Australia
  email: cngroves.std@gmail.com
- ins: J. Zhu
  name: Jintao Zhu
  org: Huawei
  street: No.127 Jinye Road, Huawei Base, High-Tech Development District
  city: Xi’an, Shaanxi Province
  code: ''
  country: China
  email: jintao.zhu@huawei.com 
- role: editor
  ins: B. Silverajan
  name: Bilhanan Silverajan
  org: Tampere University of Technology
  street: Korkeakoulunkatu 10
  city: Tampere
  code: 'FI-33720'
  country: Finland
  email: bilhanan.silverajan@tut.fi

normative:
  RFC8288: link
  RFC6690: link-format


informative:
  RFC7252: coap
  RFC7641: observe


--- abstract

This specification defines Link Bindings, which provide dynamic linking of state updates between resources, either on an endpoint or between endpoints, for systems using CoAP (RFC7252). This specification also defines Conditional Notification Attributes that work with Link Bindings or with CoAP Observe (RFC7641).
 
--- note_Editor_note
 
The git repository for the draft is found at https://github.com/core-wg/dynlink

--- middle

Introduction        {#introduction}
============

IETF Standards for machine to machine communication in constrained environments describe a REST protocol {{-coap}} and a set of related information standards that may be used to represent machine data and machine metadata in REST interfaces. CoRE Link-format {{-link-format}} is a standard for doing Web Linking {{-link}} in constrained environments. 

This specification introduces the concept of a Link Binding, which defines a new link relation type to create a dynamic link between resources over which state updates are conveyed. Specifically, a Link Binding is a unidirectional link for binding the states of source and destination resources together such that updates to one are sent over the link to the other. CoRE Link Format representations are used to configure, inspect, and maintain Link Bindings. This specification additionally defines Conditional Notification Attributes for use with Link Bindings and with the CoRE Observe {{RFC7641}} method.

Terminology     {#terminology}
===========

{::boilerplate bcp14}

This specification requires readers to be familiar with all the terms and concepts that are discussed in {{-link}} and {{RFC6690}}.  This specification makes use of the following additional terminology:

Link Binding:
: A unidirectional logical link between a source resource and a destination resource, over which state information is synchronized.

State Synchronization:
: Depending on the binding method (Polling, Observe, Push) different REST methods may be used to synchronize the resource values between a source and a destination. The process of using a REST method to achieve this is defined as "State Synchronization". The endpoint triggering the state synchronization is the synchronization initiator.

Notification Band:  
: A resource value range that results in state sychronization.  The value range may be bounded by a minimum and maximum value or may be unbounded having either a minimum or maximum value.

Conditional Notification Attributes        {#binding_attributes}
=============

This specification defines Conditional Notification Attributes, which provide for fine-grained control of notification and state synchronization when using CoRE Observe {{RFC7641}} or Link Bindings. Conditional Notification Attributes define the conditions that trigger a notification. 

When resource interfaces following this specification are made available over CoAP, the CoAP Observation mechanism {{RFC7641}} MAY also be used to observe any changes in a resource, and receive asynchronous notifications as a result. A resource marked as Observable in its link description SHOULD support these Conditional Notification Attributes.

The set of parameters defined here allow a client to control how often a client is interested in receiving notifications and how much a resource value should change for the new representation to be interesting. 

One or more Notification Attributes MAY be included as query parameters in an Observe request.

These attributes are defined below:

| Attribute         | Parameter | Value            |
| Minimum Period (s)| pmin      | xsd:decimal (>0) |
| Maximum Period (s)| pmax      | xsd:decimal (>0) |
| Change Step       | st        | xsd:decimal (>0) |
| Greater Than      | gt       | xsd:decimal      |
| Less Than         | lt       | xsd:decimal      |
| Notification Band | band     | xsd:boolean      |
{: #weblinkattributes title="Conditional Notification Attributes"}

Conditional Notification Attributes SHOULD be evaluated on all potential notifications from a resource, whether resulting from an internal sampling process or from external update requests to the server.

Note: In this draft, we assume that there are finite quantization effects in the internal or external updates to the value of a resource; specifically, that a resource may be updated at any time with any valid value. We therefore avoid any continuous-time assumptions in the description of the Conditional Observe Attributes and instead use the phrase "sampled value" to refer to a member of a sequence of values that may be internally observed from the resource state over time.
 
##Minimum Period (pmin) {#pmin}

When present, the minimum period indicates the minimum time, in seconds, between two consecutive notifications (whether or not the resource value has changed). In the absence of this parameter, the minimum period is up to the server. The minimum period MUST be greater than zero otherwise the receiver MUST return a CoAP error code 4.00 "Bad Request" (or equivalent).

A server MAY report the last sampled value that occured during the pmin interval, after the pmin interval expires. 

Note: Due to finite quantization effects, the time between notifications may be greater than pmin even when the sampled value changes within the pmin interval. Pmin may or may not be used to drive the internal sampling process.

##Maximum Period (pmax) {#pmax}
When present, the maximum period indicates the maximum time, in seconds, between two consecutive notifications (whether or not the resource value has changed). In the absence of this parameter, the maximum period is up to the server. The maximum period MUST be greater than zero and MUST be greater than the minimum period parameter (if present) otherwise the receiver MUST return a CoAP error code 4.00 "Bad Request" (or equivalent).

##Change Step (st) {#st}
When present, the change step indicates how much the value of a resource SHOULD change before triggering a notification, compared to the value of the previous notification. Upon reception of a query including the st attribute, the most recently sampled value of the resource is reported, and then set as the last reported value (last_rep_v). When a subsequent sample or update of the resource value differs from the last reported value by an amount, positive or negative, greater than or equal to st, and the time for pmin has elapsed since the last notification, a notification is sent and the last reported value is updated to the value sent in the notification. The change step MUST be greater than zero otherwise the receiver MUST return a CoAP error code 4.00 "Bad Request" (or equivalent).

The Change Step parameter can only be supported on resources with a scalar numeric value. 

Note: Due to sampling and other constraints, e.g. pmin, the resource value received in two sequential notifications may differ by more than st.

##Greater Than (gt) {#gt}
When present, Greater Than indicates the upper limit value the sampled value SHOULD cross before triggering a notification. A notification is sent whenever the sampled value crosses the specified upper limit value, relative to the last reported value, and the time fpr pmin has elapsed since the last notification. The sampled value is sent in the notification. If the value continues to rise, no notifications are generated as a result of gt. If the value drops below the upper limit value then a notification is sent, subject again to the pmin time. 

The Greater Than parameter can only be supported on resources with a scalar numeric value. 

##Less Than (lt) {#lt}
When present, Less Than indicates the lower limit value the resource value SHOULD cross before triggering a notification. A notification is sent when the samples value crosses the specified lower limit value, relative to the last reported value, and the time fpr pmin has elapsed since the last notification. The sampled value is sent in the notification. If the value continues to fall no notifications are generated as a result of lt. If the value rises above the lower limit value then a new notification is sent, subject to the pmin time.. 

The Less Than parameter can only be supported on resources with a scalar numeric value. 

##Notification Band (band) {#band}

The notification band attribute allows a bounded or unbounded (based on a minimum or maximum) value range that may trigger multiple notifications. This enables use cases where different ranges results in differing behaviour. For example: monitoring the temperature of machinery. Whilst the temperature is in the normal operating range only periodic observations are needed. However as the temperature moves to more abnormal ranges more frequent synchronization/reporting may be needed.

Without a notification band, a transition across a less than (lt), or greater than (gt) limit only generates one notification.  This means that it is not possible to describe a case where multiple notifications are sent so long as the limit is exceeded.

The band attribute works as a modifier to the behaviour of gt and lt. Therefore, if band is present in a query, gt, lt or both, MUST be included.

When band is present with the lt attribute, it defines the lower bound for the notification band (notification band minimum). Notifications occur when the resource value is equal to or above the notification band minimum. If lt is not present there is no minimum value for the band.

When band is present with the gt attribute, it defines the upper bound for the notification band (notification band maximum). Notifications occur when the resource value is equal to or below the notification band maximum. If gt is not present there is no maximum value for the band.

If band is present with both the gt and lt attributes, notification occurs when the resource value is greater than or equal to gt or when the resource value is less than or equal to lt.

If a band is specified in which the value of gt is less than that of lt, in-band notification occurs. That is, notification occurs whenever the resource value is between the gt and lt values, including equal to gt or lt. 

If the band is specified in which the value of gt is greater than that of lt, out-of-band notification occurs. That is, notification occurs when the resource value not between the gt and lt values, excluding equal to gt and lt.

The Notification Band parameter can only be supported on resources with a scalar numeric value. 

## Server processing of Conditional Notification Atributes

Pmin, pmax, st, gt and lt may be present in the same query. The server sends a notification whenever any of the parameter conditions are met, upon which it updates it's last notification value and time to prepare for the next notification. Only one notification occurs when there are multiple conditions being met at the same time. The reference code below illustrates the logic to determine when a notification is to be sent.

~~~~
bool notifiable( Resource * r ) {

#define BAND r->band
#define SCALAR_TYPE ( num_type == r->type )
#define STRING_TYPE ( str_type == r->type )
#define BOOLEAN_TYPE ( bool_type == r->type )
#define PMIN_EX ( r->last_sample_time - r->last_rep_time >= r->pmin )
#define PMAX_EX ( r->last_sample_time - r->last_rep_time > r->pmax )
#define LT_EX ( r->v < r->lt ^ r->last_rep_v < r->lt )
#define GT_EX ( r->v > r->gt ^ r->last_rep_v > r->gt )
#define ST_EX ( abs( r->v - r->last_rep_v ) >= r->st )
#define IN_BAND ( ( r->gt <= r->v && r->v <= r->lt ) || ( r->lt <= r->gt && r->gt <= r->v ) || ( r->v <= r->lt && r->lt <= r->gt ) )
#define VB_CHANGE ( r->vb != r->last_rep_vb )
#define VS_CHANGE ( r->vs != r->last_rep_vs )

  return (
    PMIN_EX &&
    ( SCALAR_TYPE ?
      ( ( !BAND && ( GT_EX || LT_EX || ST_EX || PMAX_EX ) ) ||
        ( BAND && IN_BAND && ( ST_EX || PMAX_EX) ) )
    : STRING_TYPE ?
      ( VS_CHANGE || PMAX_EX )
    : BOOLEAN_TYPE ?
      ( VB_CHANGE || PMAX_EX )
    : false )
  );
}
~~~~
{: #figattrint title="Code logic for attribute interactions for observe notification"}


Link Bindings        {#bindings}
=============
In a M2M RESTful environment, endpoints may directly exchange the content of their resources to operate the distributed system. For example, a light switch may supply on-off control information that may be sent directly to a light resource for on-off control. Beforehand, a configuration phase is necessary to determine how the resources of the different endpoints are related to each other. This can be done either automatically using discovery mechanisms or by means of human intervention and a so-called commissioning tool. 

In this specification such an abstract relationship between two resources is defined, called a link Binding. The configuration phase necessitates the exchange of binding information, so a format recognized by all CoRE endpoints is essential. This specification defines a format based on the CoRE Link-Format to represent binding information along with the rules to define a binding method which is a specialized relationship between two resources. 

The purpose of such a binding is to synchronize content updates between a source resource and a destination resource. The destination resource MAY be a group resource if the authority component of the destination URI contains a group address (either a multicast address or a name that resolves to a multicast address). Since a binding is unidirectional, the binding entry defining a relationship is present only on one endpoint. The binding entry may be located either on the source or the destination endpoint depending on the binding method. 

Conditional Notification Attributes defined in {{binding_attributes}} can be used with Link Bindings in order to customize the notification behavior and timing.

The &quot;bind&quot; attribute and Binding Methods    {#binding_methods}
---------------

A binding method defines the rules to generate the network-transfer exchanges that synchronize state between source and destination resources. By using REST methods content is sent from the source resource to the destination resource. 

This specification defines a new CoRE link attribute &quot;bind&quot;. This is the identifier for a binding method which defines the rules to synchronize the destination resource. This attribute is mandatory.

| Attribute         | Parameter | Value            |
| Binding method    | bind      | xsd:string       |
{: #bindattribute title="The bind attribute"}

The following table gives a summary of the binding methods defined in this specification.

 | Name    | Identifier  | Location    | Method        |
 | Polling | poll        | Destination | GET           |
 | Observe | obs         | Destination | GET + Observe |
 | Push    | push        | Source      | PUT           |
{: #bindsummary title="Binding Method Summary"}

The description of a binding method defines the following aspects:

Identifier: 
: This is the value of the &quot;bind&quot; attribute used to identify the method.

Location: 
: This information indicates whether the binding entry is stored on the source or on the destination endpoint.

REST Method: 
: This is the REST method used in the Request/Response exchanges.

Conditional Notification: 
: How Conditional Notification Attributes are used in the binding.

The binding methods are described in more detail below.

###Polling

The Polling method consists of sending periodic GET requests from the destination endpoint to the source resource and copying the content to the destination resource. The binding entry for this method MUST be stored on the destination endpoint. The destination endpoint MUST ensure that the polling frequency does not exceed the limits defined by the pmin and pmax attributes of the binding entry. The copying process MAY filter out content from the GET requests using value-based conditions (e.g based on the Change Step, Less Than, Greater Than attributes).

###Observe
 
The Observe method creates an observation relationship between the destination endpoint and the source resource. On each notification the content from the source resource is copied to the destination resource. The creation of the observation relationship requires the CoAP Observation mechanism {{RFC7641}} hence this method is only permitted when the resources are made available over CoAP. The binding entry for this method MUST be stored on the destination endpoint. The binding conditions are mapped as query parameters in the Observe request (see {{binding_attributes}}).

###Push 

When the Push method is assigned to a binding, the source endpoint sends PUT requests to the destination resource when the Conditional Notification Attributes are satisfied for the source resource. The source endpoint SHOULD only send a notification request if any included Conditional Notification Attributes are met. The binding entry for this method MUST be stored on the source endpoint.


Link Relation    {#relation_type}
------
Since Binding involves the creation of a link between two resources, Web Linking and the CoRE Link-Format used to represent binding information. This involves the creation of a new relation type, "boundto". In a Web link with this relation type, the target URI contains the location of the source resource and the context URI points to the destination resource. 


Binding Table     {#binding_table}
=============
The Binding table is a special resource that gives access to the bindings on a endpoint. This section defines a REST interface for Binding table resources. The Binding table resource MUST support the Binding interface defined below. The interface supports the link-format type.

The if= column defines the Interface Description (if=) attribute value to be used in the CoRE Link Format for a resource conforming to that interface. When this value appears in the if= attribute of a link, the resource MUST support the corresponding REST interface described in this section. The resource MAY support additional functionality, which is out of scope for this specification. Although this interface description is intended to be used with the CoRE Link Format, it is applicable for use in any REST interface definition. 

The Methods column defines the REST methods supported by the interface, which are described in more detail below. 

| Interface | if=      | Methods           | Content-Formats |
| Binding   | core.bnd | GET, POST, DELETE | link-format     |
{: #intdesc title="Binding Interface Description"}

The Binding interface is used to manipulate a binding table. A request with a POST method and a content format of application/link-format simply appends new bindings to the table. All links in the payload MUST have a relation type &quot;boundto&quot;. A GET request simply returns the current state of a binding table whereas a DELETE request empties the table. Individual entries may be deleted from the table by specifying the resource path in a DELETE request.

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

Req: DELETE /bnd/a/light
Res: 2.04 Changed  
  
Req: DELETE /bnd/
Res: 2.04 Changed
~~~~
{: #figbindexp title="Binding Interface Example"}

Implementation Considerations   {#Implementation}
=======================

When using multiple resource bindings (e.g. multiple Observations of resource) with different bands, consideration should be given to the resolution of the resource value when setting sequential bands. For example: Given BandA (Abmn=10, Bbmx=20) and BandB (Bbmn=21, Bbmx=30). If the resource value returns an integer then notifications for values between and inclusive of 10 and 30 will be triggered. Whereas if the resolution is to one decimal point (0.1) then notifications for values 20.1 to 20.9 will not be triggered.

The use of the notification band minimum and maximum allow for a synchronization whenever a change in the resource value occurs. Theoretically this could occur in-line with the server internal sample period for the determining the resource value. Implementors SHOULD consider the resolution needed before updating the resource, e.g. updating the resource when a temperature sensor value changes by 0.001 degree versus 1 degree.

The initiation of a link binding can be delegated from a client to a link state machine implementation, which can be an embedded client or a configuration tool. Implementation considerations have to be given to how to monitor transactions made by the configuration tool with regards to link bindings, as well as any errors that may arise with establishing link bindings as well as with established link bindings.
 
Security Considerations   {#Security}
=======================
Consideration has to be given to what kinds of security credentials the state machine of a configuration tool or an embedded client needs to be configured with, and what kinds of access control lists client implementations should possess, so that transactions on creating link bindings and handling error conditions can be processed by the state machine.

IANA Considerations
===================

Interface Description
---------------------
The specification registers the "binding" CoRE interface description link target attribute value as per {{RFC6690}}.

Attribute Value:
: core.bnd

Description: The binding interface is used to manipulate a binding table which describes the link bindings between source and destination resources for the purposes of synchronizing their content.

Reference: This specification. Note to RFC editor: please insert the RFC of this specification.

Notes: None

Link Relation Type
-------------------
This specification registers the new "boundto" link relation type as per {{-link}}.

Relation Name: 
: boundto

Description: 
: The purpose of a boundto relation type is to indicate that there is a binding between a source resource and a destination resource for the purposes of synchronizing their content.

Reference: 
: This specification. Note to RFC editor: please insert the RFC of this specification.

Notes: 
: None

Application Data: 
: None

Acknowledgements
================
Acknowledgement is given to colleagues from the SENSEI project who were critical in the initial development of the well-known REST interface concept, to members of the IPSO Alliance where further requirements for interface types have been discussed, and to Szymon Sasin, Cedric Chauvenet, Daniel Gavelle and Carsten Bormann who have provided useful discussion and input to the concepts in this specification. Christian Amsuss supplied a comprehensive review of draft -06.

Contributors
============

    Matthieu Vial
    Schneider-Electric
    Grenoble
    France

    Phone: +33 (0)47657 6522
    EMail: matthieu.vial@schneider-electric.com

Changelog
=========

draft-ietf-core-dynlink-08

* Reorganize the draft to introduce Conditional Notification Attributes at the beginning
* Made pmin and pmax type xsd:decimal to accommodate fractional second timing
* updated the attribute descriptions. lt and gt notify on all crossings, both directions


draft-ietf-core-dynlink-07

* Added reference code to illustrate attribute interactions for observations

draft-ietf-core-dynlink-06

* Document restructure and refactoring into three main sections
* Clarifications on band usage
* Implementation considerations introduced
* Additional text on security considerations

draft-ietf-core-dynlink-05

* Addition of a band modifier for gt and lt, adapted from draft-groves-core-obsattr
* Removed statement prescribing gt MUST be greater than lt

draft-ietf-core-dynlink-03

* General: Reverted to using "gt" and "lt" from "gth" and "lth" for this draft owing to concerns raised that the attributes are already used in LwM2M with the original names "gt" and "lt".

* New author and editor added. 

draft-ietf-core-dynlink-02

* General: Changed the name of the greater than attribute "gt" to "gth" and the name of the less than attribute "lt" to "lth" due to conlict with the core resource directory draft lifetime "lt" attribute.

* Clause 6.1: Addressed the editor's note by changing the link target attribute to "core.binding".

* Added Appendix A for examples.

draft-ietf-core-dynlink-01

* General: The term state synchronization has been introduced to describe the process of synchronization between destination and source resources.

* General: The document has been restructured the make the information flow better.

* Clause 3.1: The descriptions of the binding attributes have been updated to clarify their usage.

* Clause 3.1: A new clause has been added to discuss the interactions between the resources.

* Clause 3.4: Has been simplified to refer to the descriptions in 3.1. As the text was largely duplicated.

* Clause 4.1: Added a clarification that individual resources may be removed from the binding table.

* Clause 6: Formailised the IANA considerations.

draft-ietf-core-dynlink Initial Version 00:

* This is a copy of draft-groves-core-dynlink-00

draft-groves-core-dynlink Draft Initial Version 00:

* This initial version is based on the text regarding the dynamic linking functionality in I.D.ietf-core-interfaces-05.

* The WADL description has been dropped in favour of a thorough textual description of the REST API.

--- back

Examples
========

This appendix provides some examples of the use of binding attribute / observe attributes.

Note: For brevity the only the method or response code is shown in the header field.

Greater Than (gt) example
--------------------------

~~~~
     Observed   CLIENT  SERVER     Actual
 t   State         |      |         State
     ____________  |      |  ____________
 1                 |      |
 2    unknown      |      |     18.5 Cel
 3                 +----->|                  Header: GET 
 4                 | GET  |                   Token: 0x4a
 5                 |      |                Uri-Path: temperature
 6                 |      |               Uri-Query: gt="25"
 7                 |      |                 Observe: 0 (register)
 8                 |      |
 9   ____________  |<-----+                  Header: 2.05 
10                 | 2.05 |                   Token: 0x4a
11    18.5 Cel     |      |                 Observe: 9
12                 |      |                 Payload: "18.5 Cel"
13                 |      |                 
14                 |      |
15                 |      |  ____________
16   ____________  |<-----+                  Header: 2.05 
17                 | 2.05 |     26 Cel        Token: 0x4a
18    26 Cel       |      |                 Observe: 16
29                 |      |                 Payload: "26 Cel"
20                 |      |                 
21                 |      |
~~~~
{: #figbindexp1 title="Client Registers and Receives one Notification of the Current State and One of a New State when it passes through the greather than threshold of 25."}

Greater Than (gt) and Period Max (pmax) example
----------------------------------

~~~~
     Observed   CLIENT  SERVER     Actual
 t   State         |      |         State
     ____________  |      |  ____________
 1                 |      |
 2    unknown      |      |     18.5 Cel
 3                 +----->|                  Header: GET 
 4                 | GET  |                   Token: 0x4a
 5                 |      |                Uri-Path: temperature
 6                 |      |         Uri-Query: pmax="20";gt="25"
 7                 |      |                 Observe: 0 (register)
 8                 |      |
 9   ____________  |<-----+                  Header: 2.05 
10                 | 2.05 |                   Token: 0x4a
11    18.5 Cel     |      |                 Observe: 9
12                 |      |                 Payload: "18.5 Cel"
13                 |      |                 
14                 |      |
15                 |      |
16                 |      |
17                 |      |
18                 |      |
19                 |      |
20                 |      |
21                 |      |
22                 |      |
23                 |      |
24                 |      |
25                 |      |
26                 |      |
27                 |      |
28                 |      |
29                 |      |  ____________
30   ____________  |<-----+                  Header: 2.05
31                 | 2.05 |     23 Cel        Token: 0x4a
32    23 Cel       |      |                 Observe: 30
33                 |      |                 Payload: "23 Cel"
34                 |      |                 
35                 |      |
36                 |      |  ____________
37   ____________  |<-----+                  Header: 2.05 
38                 | 2.05 |     26 Cel        Token: 0x4a
39    26 Cel       |      |                 Observe: 37
40                 |      |                 Payload: "26 Cel"
41                 |      |                 
42                 |      |
~~~~
{: #figbindexp2 title="Client Registers and Receives one Notification of the Current State, one when pmax time expires and one of a new State when it passes through the greather than threshold of 25."}

