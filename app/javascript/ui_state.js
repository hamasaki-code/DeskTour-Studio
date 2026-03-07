const UI_STATE_GUARD = "__deskTourUiStateInstalled";
const FORM_DRAFT_PREFIX = "form_draft_";

const INTERACTIVE_SELECTOR = [
  "a",
  "button",
  "input",
  "select",
  "textarea",
  "label",
  "summary",
  "[role='button']",
  "[data-card-stop]",
  "[data-open-report-modal]",
  "[data-close-report-modal]",
  "[data-copy-url]"
].join(", ");

const isBlank = (value) => value == null || String(value).trim().length === 0;

const readJson = (key, fallback = {}) => {
  try {
    const raw = localStorage.getItem(key);
    if (!raw) return fallback;
    const parsed = JSON.parse(raw);
    return typeof parsed === "object" && parsed != null ? parsed : fallback;
  } catch (_) {
    return fallback;
  }
};

const writeJson = (key, value) => {
  try {
    localStorage.setItem(key, JSON.stringify(value));
  } catch (_) {}
};

const controlLabel = (field, form) => {
  if (!field) return "";

  const id = field.getAttribute("id");
  if (id) {
    const byFor = form.querySelector(`label[for='${id}']`);
    if (byFor) return byFor.textContent.replace(/\s+/g, " ").trim();
  }

  const wrapperLabel = field.closest("label");
  if (wrapperLabel) return wrapperLabel.textContent.replace(/\s+/g, " ").trim();

  return field.getAttribute("name") || field.getAttribute("aria-label") || "field";
};

const bindCardNavigation = (scope = document) => {
  scope.querySelectorAll("[data-card-href]").forEach((card) => {
    if (card.dataset.cardNavigationBound === "1") return;
    card.dataset.cardNavigationBound = "1";

    if (!card.hasAttribute("tabindex")) card.setAttribute("tabindex", "0");
    if (!card.hasAttribute("role")) card.setAttribute("role", "link");

    const navigateToCard = () => {
      const href = card.dataset.cardHref;
      if (!href) return;
      window.location.assign(href);
    };

    card.addEventListener("click", (event) => {
      if (event.defaultPrevented) return;
      if (event.target.closest(INTERACTIVE_SELECTOR)) return;
      if (window.getSelection && String(window.getSelection()).trim().length > 0) return;
      navigateToCard();
    });

    card.addEventListener("keydown", (event) => {
      if (event.target !== card) return;
      if (event.key !== "Enter" && event.key !== " ") return;
      event.preventDefault();
      navigateToCard();
    });
  });
};

const updateCharCounter = (field) => {
  const max = Number(field.dataset.charCountMax || field.getAttribute("maxlength") || "0");
  if (!Number.isFinite(max) || max <= 0) return;

  const current = String(field.value || "").length;
  const counterId = field.dataset.charCountTarget;
  const counter = counterId ? document.getElementById(counterId) : null;
  if (!counter) return;

  counter.textContent = `${current} / ${max}`;
  counter.classList.toggle("ds-char-counter-warning", current >= Math.floor(max * 0.85) && current <= max);
  counter.classList.toggle("ds-char-counter-error", current > max);
};

const bindCharCounters = (scope = document) => {
  scope.querySelectorAll("[data-char-count-max], [maxlength]").forEach((field) => {
    if (field.dataset.charCounterBound === "1") {
      updateCharCounter(field);
      return;
    }

    field.dataset.charCounterBound = "1";
    updateCharCounter(field);
    field.addEventListener("input", () => updateCharCounter(field));
    field.addEventListener("change", () => updateCharCounter(field));
  });
};

const requiredFieldBlank = (field) => {
  if (field.disabled) return false;

  if (field.type === "checkbox" || field.type === "radio") {
    if (!field.name) return !field.checked;
    const group = field.form ? field.form.querySelectorAll(`[name='${field.name}']`) : [ field ];
    return !Array.from(group).some((input) => input.checked);
  }

  return isBlank(field.value);
};

const updateFormState = (form) => {
  const reasonNode = form.querySelector("[data-disabled-reason]");
  const submitButtons = Array.from(form.querySelectorAll("button[type='submit'], input[type='submit']"));
  const requiredFields = Array.from(form.querySelectorAll("[required]"));

  const missingLabels = requiredFields
    .filter(requiredFieldBlank)
    .map((field) => controlLabel(field, form))
    .filter((label) => label.length > 0)
    .filter((label, index, list) => list.indexOf(label) === index);

  const blocked = missingLabels.length > 0 || form.dataset.uiSubmitting === "true";

  submitButtons.forEach((button) => {
    button.disabled = blocked;
    button.classList.toggle("ds-button-disabled", blocked);
    button.setAttribute("aria-disabled", String(blocked));
  });

  if (!reasonNode) return;

  if (form.dataset.uiSubmitting === "true") {
    reasonNode.textContent = form.dataset.submittingReason || "Processing...";
    return;
  }

  if (missingLabels.length > 0) {
    const preview = missingLabels.slice(0, 3).join(", ");
    const suffix = missingLabels.length > 3 ? "..." : "";
    reasonNode.textContent = `${form.dataset.disabledReasonPrefix || "Complete required fields"}: ${preview}${suffix}`;
  } else {
    reasonNode.textContent = "";
  }
};

const bindFormState = (scope = document) => {
  scope.querySelectorAll("form[data-ui-form]").forEach((form) => {
    if (form.dataset.uiFormBound === "1") {
      updateFormState(form);
      return;
    }

    form.dataset.uiFormBound = "1";
    form.dataset.uiFormDirty = "false";
    form.dataset.uiStartTracked = form.dataset.uiStartTracked || "false";
    form.dataset.uiErrorExposureTracked = form.dataset.uiErrorExposureTracked || "false";

    const draftKey = `${FORM_DRAFT_PREFIX}${form.dataset.offlineDraftKey || form.getAttribute("action") || form.id || "default"}`;
    const formContext = form.dataset.formAnalyticsContext || "generic_form";
    const serializableFields = () => Array.from(form.querySelectorAll("input[name], textarea[name], select[name]")).filter((field) => {
      const type = (field.getAttribute("type") || "").toLowerCase();
      return ![ "password", "file", "submit", "button", "image" ].includes(type);
    });

    const emitFormEvent = (name, payload = {}) => {
      if (typeof window.gtag !== "function") return;
      window.gtag("event", name, { event_category: "form", event_label: formContext, ...payload });
    };

    const trackFormStart = (field) => {
      if (form.dataset.uiStartTracked === "true") return;
      form.dataset.uiStartTracked = "true";
      emitFormEvent("form_start", {
        field_name: field?.name || "",
        form_action: form.getAttribute("action") || ""
      });
    };

    const trackErrorExposure = () => {
      if (form.dataset.uiErrorExposureTracked === "true") return;
      const invalidFields = Array.from(form.querySelectorAll("[aria-invalid='true']"));
      if (invalidFields.length === 0) return;
      form.dataset.uiErrorExposureTracked = "true";
      invalidFields.slice(0, 5).forEach((field) => {
        emitFormEvent("form_error_exposure", {
          field_name: field.getAttribute("name") || "",
          field_label: controlLabel(field, form)
        });
      });
    };

    const saveDraft = () => {
      const payload = {};
      serializableFields().forEach((field) => {
        if (field.type === "checkbox") {
          payload[field.name] = field.checked;
        } else if (field.type === "radio") {
          if (field.checked) payload[field.name] = field.value;
        } else {
          payload[field.name] = field.value;
        }
      });
      writeJson(draftKey, payload);
    };

    const restoreDraft = () => {
      const payload = readJson(draftKey, {});
      if (!payload || Object.keys(payload).length === 0) return;
      serializableFields().forEach((field) => {
        if (!(field.name in payload)) return;
        if (field.type === "checkbox") {
          field.checked = Boolean(payload[field.name]);
        } else if (field.type === "radio") {
          field.checked = String(payload[field.name]) === String(field.value);
        } else {
          field.value = payload[field.name];
        }
      });
      if (typeof window.dsNotify === "function" && form.dataset.offlineDraftKey) {
        window.dsNotify(form.dataset.draftRestoredMessage || "Draft restored.", "info");
      }
    };

    form.addEventListener("input", () => {
      const currentField = document.activeElement?.closest("input[name], textarea[name], select[name]");
      trackFormStart(currentField);
      form.dataset.uiFormDirty = "true";
      updateFormState(form);
      if (form.dataset.offlineDraftKey) saveDraft();
    });
    form.addEventListener("change", () => {
      const currentField = document.activeElement?.closest("input[name], textarea[name], select[name]");
      trackFormStart(currentField);
      form.dataset.uiFormDirty = "true";
      updateFormState(form);
      if (form.dataset.offlineDraftKey) saveDraft();
    });

    form.addEventListener("focusout", (event) => {
      const field = event.target.closest("input[name], textarea[name], select[name]");
      if (!field || typeof window.gtag !== "function") return;
      const label = controlLabel(field, form);
      const filled = !isBlank(field.value);
      window.gtag("event", "form_field_blur", {
        event_category: "form",
        event_label: form.dataset.formAnalyticsContext || "generic_form",
        field_name: field.name,
        field_label: label,
        field_filled: filled
      });
    }, true);

    form.addEventListener("submit", (event) => {
      if (!navigator.onLine) {
        event.preventDefault();
        saveDraft();
        if (typeof window.dsNotify === "function") {
          window.dsNotify(form.dataset.offlineSubmitMessage || "You appear to be offline. Your input is saved locally.", "error");
        }
        return;
      }

      updateFormState(form);
      const submitButtons = Array.from(form.querySelectorAll("button[type='submit'], input[type='submit']"));
      const blocked = submitButtons.some((button) => button.disabled);
      if (blocked) {
        event.preventDefault();
        const missingRequiredCount = Array.from(form.querySelectorAll("[required]")).filter(requiredFieldBlank).length;
        emitFormEvent("form_submit_blocked", {
          missing_required_count: missingRequiredCount
        });
        if (typeof window.dsNotify === "function") {
          window.dsNotify(form.dataset.disabledSubmitNotice || "Please complete required fields.", "error");
        }
        return;
      }

      form.dataset.uiSubmitting = "true";
      form.setAttribute("aria-busy", "true");
      form.classList.add("ds-form-submitting");
      emitFormEvent("form_submit_attempt", {
        form_action: form.getAttribute("action") || ""
      });

      const submitText = form.dataset.loadingLabel || "Processing...";
      submitButtons.forEach((button) => {
        if (!button.dataset.originalLabel) {
          button.dataset.originalLabel = button.textContent.trim();
        }

        const labelNode = button.querySelector("[data-submit-label]");
        if (labelNode) {
          labelNode.textContent = submitText;
        } else if (button.tagName === "BUTTON") {
          button.textContent = submitText;
        } else {
          button.value = submitText;
        }

        button.disabled = true;
      });

      if (form.dataset.offlineDraftKey) {
        localStorage.removeItem(draftKey);
      }

      updateFormState(form);
    });

    restoreDraft();
    updateFormState(form);
    trackErrorExposure();
  });
};

const bindFormAbandonmentObserver = () => {
  if (window.__formAbandonmentBound) return;
  window.__formAbandonmentBound = true;

  window.addEventListener("beforeunload", () => {
    if (typeof window.gtag !== "function") return;
    const dirtyForm = document.querySelector("form[data-ui-form][data-ui-form-dirty='true']");
    if (!dirtyForm) return;
    const active = dirtyForm.querySelector(":focus");
    const activeField = active ? active.getAttribute("name") : "";
    window.gtag("event", "form_abandon", {
      event_category: "form",
      event_label: dirtyForm.dataset.formAnalyticsContext || "generic_form",
      active_field: activeField
    });
  });
};

const renderImageFallback = (image, reason = "error") => {
  if (!image) return;

  const shell = image.closest("[data-image-shell]");
  if (!shell) return;

  const fallbackSrc = image.dataset.fallbackSrc;
  if (isBlank(fallbackSrc)) return;

  if (image.dataset.originalSrc == null) {
    image.dataset.originalSrc = image.getAttribute("src") || "";
  }

  if (reason === "error" && image.dataset.fallbackApplied !== "1") {
    image.dataset.fallbackApplied = "1";
    image.src = fallbackSrc;
  }

  const fallbackNode = shell.querySelector("[data-image-fallback]");
  if (fallbackNode) fallbackNode.classList.remove("hidden");
};

const bindImageFallback = (scope = document) => {
  scope.querySelectorAll("img[data-fallback-src]").forEach((image) => {
    if (image.dataset.fallbackBound === "1") return;
    image.dataset.fallbackBound = "1";

    image.addEventListener("error", () => {
      renderImageFallback(image, "error");
    });
  });

  scope.querySelectorAll("[data-image-retry]").forEach((button) => {
    if (button.dataset.imageRetryBound === "1") return;
    button.dataset.imageRetryBound = "1";

    button.addEventListener("click", () => {
      const shell = button.closest("[data-image-shell]");
      const image = shell ? shell.querySelector("img[data-fallback-src]") : null;
      if (!image) return;

      const originalSrc = image.dataset.originalSrc || "";
      if (isBlank(originalSrc)) return;

      image.dataset.fallbackApplied = "0";
      image.src = `${originalSrc}${originalSrc.includes("?") ? "&" : "?"}retry=${Date.now()}`;

      const fallbackNode = shell.querySelector("[data-image-fallback]");
      if (fallbackNode) fallbackNode.classList.add("hidden");
    });
  });
};

const bindLoadingSkeleton = (scope = document) => {
  scope.querySelectorAll("[data-loading-state]").forEach((container) => {
    if (container.dataset.loadingStateBound === "1") return;
    container.dataset.loadingStateBound = "1";

    const skeleton = container.querySelector("[data-loading-skeleton]");
    const content = container.querySelector("[data-loading-content]");
    if (!skeleton || !content) return;

    container.addEventListener("ds:loading:start", () => {
      skeleton.classList.remove("hidden");
      content.classList.add("hidden");
      container.setAttribute("aria-busy", "true");
    });

    container.addEventListener("ds:loading:stop", () => {
      skeleton.classList.add("hidden");
      content.classList.remove("hidden");
      container.removeAttribute("aria-busy");
    });
  });
};

const bindTapFeedback = () => {
  const selector = ".cta-primary, .cta-secondary, .cta-tertiary, .cta-warning, .cta-danger, [data-tap-feedback]";

  const activate = (event) => {
    const target = event.target.closest(selector);
    if (!target) return;
    target.classList.add("ds-tap-active");
  };

  const deactivate = () => {
    document.querySelectorAll(".ds-tap-active").forEach((node) => node.classList.remove("ds-tap-active"));
  };

  document.addEventListener("pointerdown", activate, { passive: true });
  document.addEventListener("pointerup", deactivate, { passive: true });
  document.addEventListener("pointercancel", deactivate, { passive: true });
  document.addEventListener("touchend", deactivate, { passive: true });
};

const showFlashToasts = (scope = document) => {
  const flashNodes = scope.querySelectorAll("[data-flash-message]");
  if (flashNodes.length === 0) return;

  flashNodes.forEach((node) => {
    if (node.dataset.toastDisplayed === "1") return;
    node.dataset.toastDisplayed = "1";

    const message = node.dataset.flashMessage;
    const level = node.dataset.flashLevel || "info";
    if (typeof window.dsNotify === "function") {
      window.setTimeout(() => window.dsNotify(message, level), 90);
    }
  });
};

const initializeUiState = (scope = document) => {
  bindCardNavigation(scope);
  bindCharCounters(scope);
  bindFormState(scope);
  bindFormAbandonmentObserver();
  bindImageFallback(scope);
  bindLoadingSkeleton(scope);
  showFlashToasts(scope);
};

if (!window[UI_STATE_GUARD]) {
  window[UI_STATE_GUARD] = true;

  const connection = navigator.connection || navigator.mozConnection || navigator.webkitConnection;
  const lowBandwidth = Boolean(connection && (connection.saveData || /(^|[^0-9])2g/i.test(connection.effectiveType || "")));
  if (lowBandwidth) {
    document.documentElement.classList.add("ds-low-bandwidth");
  }

  const ua = navigator.userAgent || "";
  if (/iPhone|iPad|iPod/i.test(ua)) document.documentElement.classList.add("platform-ios");
  if (/Android/i.test(ua)) document.documentElement.classList.add("platform-android");

  window.addEventListener("online", () => {
    document.documentElement.classList.remove("ds-offline");
    if (typeof window.dsNotify === "function") window.dsNotify("Back online.", "success");
  });
  window.addEventListener("offline", () => {
    document.documentElement.classList.add("ds-offline");
    if (typeof window.dsNotify === "function") window.dsNotify("You are offline. Inputs will be saved locally.", "error");
  });

  bindTapFeedback();

  document.addEventListener("turbo:before-fetch-request", () => {
    document.documentElement.classList.add("ds-page-loading");
  });

  document.addEventListener("turbo:fetch-request-error", () => {
    document.documentElement.classList.remove("ds-page-loading");
  });

  document.addEventListener("turbo:load", () => {
    document.documentElement.classList.remove("ds-page-loading");
    initializeUiState(document);
  });

  document.addEventListener("DOMContentLoaded", () => {
    initializeUiState(document);
  });
}
