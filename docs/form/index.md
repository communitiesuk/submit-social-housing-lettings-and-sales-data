---
has_children: true
nav_order: 9
---

# Generating forms

Social housing lettings and sales data is collected in annual collection windows that run from 1 April to 1 April the following year.

During this window the form and questions generally stay constant. The form will generally change by small amounts between each collection window. Typical changes are adding new questions, adding or removing answer options from questions or tweaking question wording for clarity.

A paper form is produced for guidance and to help data providers collect the data offline, and a bulk upload template is circulated which need to match the online form.

Data is accepted for a collection window for up to 3 months after it’s finished to allow for late data submission. This means that between April and July 2 versions of the form run simultaneously.

Other initial considerations that went into our design are being able to re-use as much of this solution for other data collections, and possibly having the ability to generate the form and/or form changes from a user interface.

Each form has historically been defined as a JSON configuration, but has since been replaced with subsection, page and question classes that contruct a form in code due to increased complexity.

To allow for easier content changes, the copy for questions has been extracted into translation files. The reasoning for this is the following assumptions:

- The form will be tweaked regularly (amending questions wording, changing the order of questions or the page a question is displayed on)

- The actual data collected will change very infrequently. Time series continuity is very important to ADD (Analysis and Data Directorate) so the actual data collected should stay largely consistent i.e. in general we can change the question wording in ways that makes the intent clearer or easier to understand, but not in ways that would make the data provider give a different answer.
