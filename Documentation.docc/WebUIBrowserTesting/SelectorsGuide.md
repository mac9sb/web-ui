# Selectors Guide

## CSS Selectors

```swift
let submit = await page.querySelector("#submit")
let items = await page.querySelectorAll(".menu-item")
```

## XPath

```swift
let button = await page.xpath("//button[@type='submit']")
```

## Text and Roles

```swift
let submit = await page.getByText("Submit")
let save = await page.getByRole(.button, name: "Save")
```

## Test IDs

```swift
let loginForm = await page.getByTestId("login-form")
```
