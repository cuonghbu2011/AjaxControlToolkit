﻿<%@ Page Title="" Language="C#" MasterPageFile="~/Suites/Suite.Master" AutoEventWireup="true" CodeBehind="HtmlEditorExtenderTests.aspx.cs" Inherits="AjaxControlToolkit.Jasmine.Suites.HtmlEditorExtenderTests" %>

<asp:Content ContentPlaceHolderID="TestSuiteName" runat="server">
    HtmlEditorExtender
</asp:Content>

<asp:Content ContentPlaceHolderID="TestSuite" runat="server">
    <asp:UpdatePanel runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:TextBox runat="server"
                ID="Target"
                Width="500"
                Height="300" />

            <act:HtmlEditorExtender runat="server"
                TargetControlID="Target" 
                ID="TargetExtender" 
                EnableSanitization="false" 
                DisplaySourceTab="true">
                <Toolbar>
                    <act:Undo />
                    <act:Redo />
                    <act:Bold />
                    <act:Italic />
                    <act:Underline />
                    <act:StrikeThrough />
                    <act:Subscript />
                    <act:Superscript />
                    <act:JustifyLeft />
                    <act:JustifyCenter />
                    <act:JustifyRight />
                    <act:JustifyFull />
                    <act:InsertOrderedList />
                    <act:InsertUnorderedList />
                    <act:CreateLink />
                    <act:UnLink />
                    <act:RemoveFormat />
                    <act:SelectAll />
                    <act:UnSelect />
                    <act:Delete />
                    <act:Cut />
                    <act:Copy />
                    <act:Paste />
                    <act:BackgroundColorSelector />
                    <act:ForeColorSelector />
                    <act:FontNameSelector />
                    <act:FontSizeSelector />
                    <act:Indent />
                    <act:Outdent />
                    <act:InsertHorizontalRule />
                    <act:HorizontalSeparator />
                    <act:InsertImage />
                </Toolbar>
            </act:HtmlEditorExtender>

            <asp:TextBox runat="server"
                ID="TargetSanitized"
                Width="500"
                Height="300" />

            <act:HtmlEditorExtender runat="server"
                TargetControlID="TargetSanitized" 
                ID="TargetExtenderSanitized" 
                EnableSanitization="true" 
                DisplaySourceTab="true">
                <Toolbar>
                    <act:Undo />
                    <act:Redo />
                    <act:Bold />
                    <act:Italic />
                    <act:Underline />
                    <act:StrikeThrough />
                    <act:Subscript />
                    <act:Superscript />
                    <act:JustifyLeft />
                    <act:JustifyCenter />
                    <act:JustifyRight />
                    <act:JustifyFull />
                    <act:InsertOrderedList />
                    <act:InsertUnorderedList />
                    <act:CreateLink />
                    <act:UnLink />
                    <act:RemoveFormat />
                    <act:SelectAll />
                    <act:UnSelect />
                    <act:Delete />
                    <act:Cut />
                    <act:Copy />
                    <act:Paste />
                    <act:BackgroundColorSelector />
                    <act:ForeColorSelector />
                    <act:FontNameSelector />
                    <act:FontSizeSelector />
                    <act:Indent />
                    <act:Outdent />
                    <act:InsertHorizontalRule />
                    <act:HorizontalSeparator />
                    <act:InsertImage />
                </Toolbar>
            </act:HtmlEditorExtender>

            <asp:Button ID="SubmitButton" runat="server" Text="Submit button" ClientIDMode="Static"/>
        </ContentTemplate>
    </asp:UpdatePanel>

    <script>
        describe("HtmlEditorExtender", function() {

            var HTML_EDITOR_EXTENDER_CLIENT_ID = "<%= TargetExtender.ClientID %>",
                HTML_EDITOR_EXTENDER_SANITIZED_CLIENT_ID = "<%= TargetExtenderSanitized.ClientID %>";

            var HTML_EDITOR_COLOR_PICKER_CONTAINER_CLASS_NAME = "ajax__colorPicker";

            beforeEach(function() {
                this.extender = $find(HTML_EDITOR_EXTENDER_CLIENT_ID);
                this.extenderSanitized = $find(HTML_EDITOR_EXTENDER_SANITIZED_CLIENT_ID);

                this.ua = detect.parse(navigator.userAgent);
            });

            it("rejects select click target", function () {
                var target = { tagName: "SELECT" };
                expect(this.extender.isValidTarget(target)).toBeFalsy();
            }),

            it("does not throw exception on submit if text is empty", function() {
                expect($.proxy(function() {
                    this.extender._editableDiv_submit();
                }, this)).not.toThrow();
            });

            it("checks if element is HTML DOM element properly", function() {
                var htmlElement = $("<div>").get(0);

                expect(this.extender._isHtmlElement(htmlElement)).toBeTruthy()
                expect(this.extender._isHtmlElement("test string element")).toBeFalsy();
            });

            // CodePlex items 27744, 27717, 27745
            it("does not throw exception on submit if editor has HTML content", function() {
                var wrapper = new HtmlEditorWrapper(this.extender);
                wrapper.setContent("lorem ipsum dolor sit amet").selectText().pressToolbarButtons(["bold", "italic", "underline"]);

                expect($.proxy(function() {
                    this.extender._editableDiv_submit();
                }, this)).not.toThrow();
            });

            it("does not throw exception on submit if editor has HTML content with extremely short text", function() {
                var wrapper = new HtmlEditorWrapper(this.extender);
                wrapper.setContent("a").selectText().pressToolbarButtons(["bold", "italic", "underline"]);

                expect($.proxy(function() {
                    this.extender._editableDiv_submit();
                }, this)).not.toThrow();
            });

            it("renders all buttons", function() {
                var wrapper = new HtmlEditorWrapper(this.extender);

                for(var button in wrapper.TOOLBAR_BUTTONS) {
                    var $button = $(wrapper.TOOLBAR_BUTTONS[button].toClassSelector());
                    expect(wrapper.currentState.containsElement($button)).toBeTruthy("button name <" + button + ">");
                }
            });

            //CodePlex item 27860
            it("does not break html markup after submit if link contains title attribute", function(done) {
                var sourceText = 'lorem <a href="lipsum.com" title="Lorem ipsum">ipsum</a>';

                var wrapper = new HtmlEditorWrapper(this.extender);
                wrapper.setContent(sourceText, "source");

                var endRequestHandler = function() {
                    var extender = $find("<%= TargetExtender.ClientID %>"),
                        wrapper = new HtmlEditorWrapper(extender);

                    expect(wrapper.currentState.editorContent()).toEqual("lorem ipsum");

                    Sys.WebForms.PageRequestManager.getInstance().remove_endRequest(arguments.callee);

                    done();
                };

                Sys.WebForms.PageRequestManager.getInstance().add_endRequest(endRequestHandler);

                $("#SubmitButton").click();
            });

            //CodePlex item 27860
            it("does not break html markup after submit if link contains style attribute with [*-]position property", function(done) {
                var sourceText = "<a href='lipsum.com' style='position: absolute; background-position: initial;'>dolor sit amet</a>";

                var wrapper = new HtmlEditorWrapper(this.extender);
                wrapper.setContent(sourceText, "source");

                var endRequestHandler = function() {
                    var extender = $find("<%= TargetExtender.ClientID %>"),
                        wrapper = new HtmlEditorWrapper(extender);

                    expect(wrapper.currentState.editorContent()).toEqual("dolor sit amet");

                    Sys.WebForms.PageRequestManager.getInstance().remove_endRequest(arguments.callee);

                    done();
                };

                Sys.WebForms.PageRequestManager.getInstance().add_endRequest(endRequestHandler);

                $("#SubmitButton").click();
            });

            it("bold button works properly", function() {
                var testContentText = "lorem ipsum dolor sit amet",
                    expectedSourceText = this.ua.browser.family === "IE" ? "<strong>lorem</strong> ipsum dolor sit amet" : "<b>lorem</b> ipsum dolor sit amet",
                    actualSourceText;

                var wrapper = new HtmlEditorWrapper(this.extender);
                wrapper.setContent(testContentText).selectText(0, 5).pressToolbarButtons(["bold"]);

                actualSourceText = wrapper.currentState.editorContent("source");
                expect(actualSourceText).toEqual(expectedSourceText);

                wrapper.pressToolbarButtons(["bold"]);

                actualSourceText = wrapper.currentState.editorContent("source");
                expect(actualSourceText).toEqual(testContentText);
            });

            it("italic button works properly", function() {
                var testContentText = "lorem ipsum dolor sit amet",
                    expectedSourceText = this.ua.browser.family === "IE" ? "<em>lorem</em> ipsum dolor sit amet" : "<i>lorem</i> ipsum dolor sit amet",
                    actualSourceText;

                var wrapper = new HtmlEditorWrapper(this.extender);
                wrapper.setContent(testContentText).selectText(0, 5).pressToolbarButtons(["italic"]);

                actualSourceText = wrapper.currentState.editorContent("source");
                expect(actualSourceText).toEqual(expectedSourceText);

                wrapper.pressToolbarButtons(["italic"]);

                actualSourceText = wrapper.currentState.editorContent("source");
                expect(actualSourceText).toEqual(testContentText);
            });

            it("underline button works properly", function() {
                var testContentText = "lorem ipsum dolor sit amet",
                    expectedSourceText = "<u>lorem</u> ipsum dolor sit amet",
                    actualSourceText;

                var wrapper = new HtmlEditorWrapper(this.extender);
                wrapper.setContent(testContentText).selectText(0, 5).pressToolbarButtons(["underline"]);

                actualSourceText = wrapper.currentState.editorContent("source");
                expect(actualSourceText).toEqual(expectedSourceText);

                wrapper.pressToolbarButtons(["underline"]);

                actualSourceText = wrapper.currentState.editorContent("source");
                expect(actualSourceText).toEqual(testContentText);
            });

            it("strike through button works properly", function() {
                var testContentText = "lorem ipsum dolor sit amet",
                    expectedSourceText = "<strike>lorem</strike> ipsum dolor sit amet",
                    actualSourceText;

                var wrapper = new HtmlEditorWrapper(this.extender);
                wrapper.setContent(testContentText).selectText(0, 5).pressToolbarButtons(["strike-through"]);

                actualSourceText = wrapper.currentState.editorContent("source");
                expect(actualSourceText).toEqual(expectedSourceText);

                wrapper.pressToolbarButtons(["strike-through"]);

                actualSourceText = wrapper.currentState.editorContent("source");
                expect(actualSourceText).toEqual(testContentText);
            });

            it("subscript button works properly", function() {
                var testContentText = "lorem ipsum dolor sit amet",
                    expectedSourceText = "<sub>lorem</sub> ipsum dolor sit amet",
                    actualSourceText;

                var wrapper = new HtmlEditorWrapper(this.extender);
                wrapper.setContent(testContentText).selectText(0, 5).pressToolbarButtons(["subscript"]);

                actualSourceText = wrapper.currentState.editorContent("source");
                expect(actualSourceText).toEqual(expectedSourceText);

                wrapper.pressToolbarButtons(["subscript"]);

                actualSourceText = wrapper.currentState.editorContent("source");
                expect(actualSourceText).toEqual(testContentText);
            });

            it("superscript button works properly", function() {
                var testContentText = "lorem ipsum dolor sit amet",
                    expectedSourceText = "<sup>lorem</sup> ipsum dolor sit amet",
                    actualSourceText;

                var wrapper = new HtmlEditorWrapper(this.extender);
                wrapper.setContent(testContentText).selectText(0, 5).pressToolbarButtons(["superscript"]);

                actualSourceText = wrapper.currentState.editorContent("source");
                expect(actualSourceText).toEqual(expectedSourceText);

                wrapper.pressToolbarButtons(["superscript"]);

                actualSourceText = wrapper.currentState.editorContent("source");
                expect(actualSourceText).toEqual(testContentText);
            });

            it("saveSelection method doesn't throw exception if no text selected", function() {
            	expect(this.extender.saveSelection).not.toThrow();
            });

            it("_executeCommand method doesn't throw exception if forecolor button is pressed", function() {
                var command = new Sys.UI.DomEvent({
                    type: "click",
                    target: (new HtmlEditorWrapper(this.extender).getButtonElement("fore-color-selector"))
                });

                var that = this;
                expect(function() {
                    that.extender._executeCommand(command);
                }).not.toThrow();
            });

            it("shows color selector after forecolor button is pressed", function() {
                var foreColorButtonName = "fore-color-selector",
                    wrapper = new HtmlEditorWrapper(this.extender);

                wrapper.setContent("lorem ipsum").selectText(0, 5).pressToolbarButtons([foreColorButtonName]);

                var $parent = $(wrapper.getButtonElement(foreColorButtonName)).parent();

                expect($parent.children(HTML_EDITOR_COLOR_PICKER_CONTAINER_CLASS_NAME.toClassSelector())).toBeTruthy();
                expect($parent.children(HTML_EDITOR_COLOR_PICKER_CONTAINER_CLASS_NAME.toClassSelector()).is(":visible")).toBeTruthy();
            });

            it("_executeCommand method doesn't throw exception if backcolor button is pressed", function() {
                var command = new Sys.UI.DomEvent({
                    type: "click",
                    target: (new HtmlEditorWrapper(this.extender).getButtonElement("back-color-selector"))
                });

                var that = this;
                expect(function() {
                    that.extender._executeCommand(command);
                }).not.toThrow();
            });

            it("show color selector after backcolor button is pressed", function() {
                var backColorButtonName = "back-color-selector",
                    wrapper = new HtmlEditorWrapper(this.extender);

                wrapper.setContent("lorem ipsum").selectText(0, 5).pressToolbarButtons([backColorButtonName]);

                var $parent = $(wrapper.getButtonElement(backColorButtonName)).parent();

                expect($parent.children(HTML_EDITOR_COLOR_PICKER_CONTAINER_CLASS_NAME.toClassSelector())).toBeTruthy();
                expect($parent.children(HTML_EDITOR_COLOR_PICKER_CONTAINER_CLASS_NAME.toClassSelector()).is(":visible")).toBeTruthy();
            });

            it("doesn't throw exception on multiple file upload", function(done) {
                var wrapper = new HtmlEditorWrapper(this.extender);
                wrapper.pressToolbarButtons(["insert-image"]);

                var ajaxFileUpload = $find(this.extender._id + "_ajaxFileUpload");
                
                var ua = detect.parse(navigator.userAgent);
                    imageUrl = (ua.browser.family === "Firefox" ? "HtmlEditorExtenderTests/" : "") + "superhero.png";

                var xhr = new XMLHttpRequest();
                xhr.open("GET", imageUrl, true);
                xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
                xhr.responseType = 'blob';

                var that = this;
                xhr.onload = function(e) {
                    if(this.status == 200) {
                        var file = this.response;
                        file.lastModifiedDate = new Date();
                        file.name = "superhero.png";

                        var fakeFile1 = {
                            id: "4c378c77-efc1-40b2-9e63-a6921d55f4d3",
                            value: file,
                            type: "png",
                            uploaded: false,
                            slices: 0
                        };
                        var fakeFile2 = {
                            id: "13596832-a7ba-40d5-81fc-b6354a82515d",
                            value: file,
                            type: "png",
                            uploaded: false,
                            slices: 0
                        };

                        ajaxFileUpload.addFileToQueue(fakeFile1);
                        ajaxFileUpload.addFileToQueue(fakeFile2);

                        var $uploadButton = $(that.extender._popupDiv).find(".ajax__fileupload_uploadbutton");
                        $uploadButton.click();

                        var handlerCallCount = 0;

                        ajaxFileUpload._events._list.uploadComplete = []
                        ajaxFileUpload._events._list["uploadComplete"].push(function(sender, e) {
                            handlerCallCount += 1;

                            expect(function() {
                                window.ajaxClientUploadComplete(sender, e);
                            }).not.toThrow();

                            if(handlerCallCount === 2)
                                done();
                        });
                    }
                };

                xhr.send();
            });

            it("doesn't add an '&' symbol after postback if the text contains '<' and '>' symbols", function(done) {
                var wrapper = new HtmlEditorWrapper(this.extender);
                wrapper.setContent("< >");

                var endRequestHandler = function() {
                    var extender = $find("<%= TargetExtender.ClientID %>"),
                        wrapper = new HtmlEditorWrapper(extender);

                    expect(wrapper.currentState.editorContent()).toEqual("< >");

                    Sys.WebForms.PageRequestManager.getInstance().remove_endRequest(arguments.callee);

                    done();
                };

                Sys.WebForms.PageRequestManager.getInstance().add_endRequest(endRequestHandler);

                $("#SubmitButton").click();
            });

            it("removes all link href attribute value with javascript code after postback", function(done) {
                var wrapper = new HtmlEditorWrapper(this.extenderSanitized);
                wrapper.switchTab("source").setContent("<a href='javascript:alert(\"hello world\");'>test link</a>");

                var endRequestHandler = function() {
                    var extender = $find("<%= TargetExtenderSanitized.ClientID %>"),
                        wrapper = new HtmlEditorWrapper(extender);

                    expect(wrapper.currentState.editorContent("source")).toEqual("<a href=\"\">test link</a>");

                    done();
                };

                Sys.WebForms.PageRequestManager.getInstance().add_endRequest(endRequestHandler);

                $("#SubmitButton").click();
            });
        });
    </script>

</asp:Content>