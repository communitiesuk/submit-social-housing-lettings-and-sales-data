---
has_children: true
nav_order: 8
---

# Generating forms

Social housing lettings and sales data is collected in annual collection windows that run from 1 April to 1 April the following year.

During this window the form and questions generally stay constant. The form will generally change by small amounts between each collection window. Typical changes are adding new questions, adding or removing answer options from questions or tweaking question wording for clarity.

A paper form is produced for guidance and to help data providers collect the data offline, and a bulk upload template is circulated which need to match the online form.

Data is accepted for a collection window for up to 3 months after it’s finished to allow for late data submission. This means that between April and July 2 versions of the form run simultaneously.

Other considerations that went into our design are being able to re-use as much of this solution for other data collections, and possibly having the ability to generate the form and/or form changes from a user interface.

We haven’t used micro-services, preferring to deploy a single application but we have modelled the form itself as configuration in the form of a JSON structure that acts as a sort of DSL/form builder for the form.

The idea is to decouple the code that creates the required routes, controller methods, views etc to display the form from the actual wording of questions or order of pages such that it becomes possible to make changes to the form with little or no code changes.

This should also mean that in the future it could be possible to create an interface that can construct the JSON config, which would open up the ability to make form changes to a wider audience. Doing this fully would require generating and running the necessary migrations for data storage, generating the required ActiveRecord methods to validate the data server side, and generating/updating API endpoints and documentation. All of this is likely to be beyond the scope of initial MVP but could be looked at in the future.

Since initially the JSON config will not create database migrations or ActiveRecord model validations, it will instead assume that these have been correctly created for the config provided. The reasoning for this is the following assumptions:

- The form will be tweaked regularly (amending questions wording, changing the order of questions or the page a question is displayed on)

- The actual data collected will change very infrequently. Time series continuity is very important to ADD (Analysis and Data Directorate) so the actual data collected should stay largely consistent i.e. in general we can change the question wording in ways that makes the intent clearer or easier to understand, but not in ways that would make the data provider give a different answer.

A form parser class will parse this config into ruby objects/methods that can be used as an API by the rest of the application, such that we could change the underlying config if needed (for example swap JSON for YAML or for DataBase objects) without needing to change the rest of the application. We’ll call this the Form Runner part of the application.
