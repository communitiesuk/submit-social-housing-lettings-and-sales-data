---
parent: Architecture decisions
---

# 018: Setup this log section

Originally the "Setup this lettings log" section of the form was included in the JSON form definition for each form year, the same as any other section, because it mostly had the same behaviour as all other sections. It could be treated as pure configuration like the rest of the form.

This increasingly stopped being true as further design requirements were added:

- The setup section needs to be completed first unlike all other sections which can be completed in any order
- Changing answers in the setup section potentially invalidates large parts of the rest of the form
- The setup question started including questions that needed to know a lot more about the application context than was reasonable for pure config in order to support Support User journeys (e.g. some questions should only show for specific user types, some answer options should only show for specific organisations etc)
- This section can't easily change between form years as other sections can as it's essential to determining what questions to show next (effectively this section is equivalent to the ~8 different form links the old system had)

The amount of application context needed to make it work is what ultimately drove the decision to make the section out of config and into code since trying to include that in JSON would require the JSON to be even more tightly coupled to the code than it already is and would dramatically increase the complexity of the JSON "DSL".

Instead the setup section is now composed of coded Ruby class in `app/models/form/setup`.

It still has all the same components as before:
- Section 
- Subsection
- Pages
- Questions

And each of these are subclasses of the generic class, which can have more application specific logic included.

Now, when the `FormHandler` singleton class instantiates each form, the `Form` class constructor also first instantiates the setup section (which sets up it's own subsections, which in turn setup their own pages etc), and then sets up the rest of the form sections, subsections etc. The end result is that the `FormHandler` still holds a reference to each form, and each form still includes the setup section as it did before when the setup section was included in the JSON form definition, just that now it's easier to include more custom behaviour in that section.
